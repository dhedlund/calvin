defmodule Calvin.RFC5234.Operators do
  def alternative(rest, tokenizers, acc \\ :nomatch)
  def alternative(_rest, [], :nomatch), do: :nomatch
  def alternative(rest, [t|ts], :nomatch) do
    alternative(rest, ts, tokenize(rest, t))
  end
  def alternative(_rest, _, acc), do: acc

  def concatenate(rest, tokenizers, acc \\ [])
  def concatenate(_rest, _tokenizers, :nomatch), do: :nomatch
  def concatenate(rest, [], acc), do: {Enum.reverse(acc), rest}
  def concatenate(rest, [tokenizer|ts], acc) do
    {new_acc, new_rest} = case tokenize(rest, tokenizer) do
      {{_,_} = token, rest} -> {[token|acc], rest}
      :nomatch -> {:nomatch, rest}
    end

    concatenate(new_rest, ts, new_acc)
  end

  def repetition(rest, tokenizer, min, max, acc \\ [])
  def repetition(_rest, _tokenizer, _min, _max, :nomatch), do: :nomatch
  def repetition(rest, _tokenizer, _min, 0, acc), do: {Enum.reverse(acc),rest}
  def repetition(rest, tokenizer, min, max, acc) do
    result = tokenize(rest, tokenizer)

#   IO.puts("")
#   IO.inspect(%{
#     result: result,
#     rest: rest,
#     tokenizer: tokenizer,
#     min: min,
#     max: max,
#     acc: acc
#   })

    {new_acc, new_rest, new_max} = case {min, result} do
      {_min, {token, rest}} -> {[token|acc], rest, decrement(max)}
      {0, :nomatch} -> {acc, rest, 0} # Minimum met, stop iterating
      _ -> {:nomatch, rest, 0} # Out of matches, but minimum not met
    end

    repetition(new_rest, tokenizer, decrement(min), new_max, new_acc)
  end

  def tokenize(rest, t) when is_atom(t), do: apply(__MODULE__, t, [rest])
  def tokenize(rest, t) when is_binary(t), do: match_literal(rest, t)
  def tokenize(rest, t) when is_function(t), do: t.(rest)

  defp decrement(:infinity), do: :infinity
  defp decrement(value) when value <= 0, do: 0
  defp decrement(value), do: value - 1

  defp match_literal(rest, match) do
    s = byte_size(match)
    case rest do
      << ^match :: binary-size(s), new_rest :: binary >> ->
        {match, new_rest}
      _  ->
        :nomatch
    end
  end

end

defmodule Calvin.RFC5234 do
  import Calvin.RFC5234.Operators

  def alpha(<<chr,rest::binary>>) when chr in ?A..?Z, do: {{:alpha, <<chr>>}, rest}
  def alpha(<<chr,rest::binary>>) when chr in ?a..?z, do: {{:alpha, <<chr>>}, rest}
  def alpha(_), do: :nomatch

  def bit("0" <> rest), do: {{:bit, "0"}, rest}
  def bit("1" <> rest), do: {{:bit, "1"}, rest}
  def bit(_), do: :nomatch

  def char(<<chr,rest::binary>>) when chr in 0x01..0x7f, do: {{:char, <<chr>>}, rest}
  def char(_), do: :nomatch

  def cr("\r" <> rest), do: {{:cr, "\r"}, rest}
  def cr(_), do: :nomatch

  def crlf(rest) do
    case concatenate(rest, [:cr, :lf]) do
      {token, rest} -> {{:crlf, token}, rest}
      :nomatch -> :nomatch
    end
  end

  def ctl(<<chr,rest::binary>>) when chr in 0x00..0x1f, do: {{:ctl, <<chr>>}, rest}
  def ctl(<<chr,rest::binary>>) when chr == 0x7f, do: {{:ctl, <<chr>>}, rest}
  def ctl(_), do: :nomatch

  def digit(<<chr,rest::binary>>) when chr in ?0..?9, do: {{:digit, <<chr>>}, rest}
  def digit(_), do: :nomatch

  def dquote("\"" <> rest), do: {{:dquote, "\""}, rest}
  def dquote(_), do: :nomatch

  def hexdig(rest) do
    case alternative(rest, [:digit, "A", "B", "C", "D", "E", "F"]) do
      {token, rest} -> {{:hexdig, token}, rest}
      :nomatch -> :nomatch
    end
  end

  def htab("\t" <> rest), do: {{:htab, "\t"}, rest}
  def htab(_), do: :nomatch

  def lf("\n" <> rest), do: {{:lf, "\n"}, rest}
  def lf(_), do: :nomatch

  def lwsp(rest) do
    # Alternative implementation of the nested function below:
    # crlf_wsp = fn rest -> concatenate(rest, [:crlf, :wsp]) end
    # wsp_or_crlf_wsp = fn rest -> alternative(rest, [:wsp, crlf_wsp]) end
    # result = repetition(rest, wsp_or_crlf_wsp, 0, :infinity)

    result = repetition(rest, fn rest ->
      alternative(rest, [:wsp, fn rest ->
        concatenate(rest, [:crlf, :wsp])
      end])
    end, 0, :infinity)

    case result do
      {token, rest} -> {{:lwsp, token}, rest}
      :nomatch -> :nomatch
    end
  end

  def octet(<<chr,rest::binary>>) when chr in 0x00..0xff, do: {{:octet, <<chr>>}, rest}
  def octet(_), do: :nomatch

  def sp(" " <> rest), do: {{:sp, " "}, rest}
  def sp(_), do: :nomatch

  def vchar(<<chr,rest::binary>>) when chr in 0x21..0x7e, do: {{:vchar, <<chr>>}, rest}
  def vchar(_), do: :nomatch

  def wsp(rest) do
    case alternative(rest, [:sp, :htab]) do
      {token, rest} -> {{:wsp, token}, rest}
      :nomatch -> :nomatch
    end
  end
end
