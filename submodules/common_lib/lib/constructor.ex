defmodule CommonLib.Constructor do
  alias CommonLib.Constructor.BuiltInType

  defmacro __using__(_opts) do
    quote do
      use Constructor
      import CommonLib.Constructor, only: [required: 1, optional: 1, list_of: 1]
    end
  end

  defmacro required(type) when is_atom(type) do
    quote do
      {CommonLib.Constructor, :required, [unquote(type)]}
    end
  end

  defmacro required({type, opts}) when is_atom(type) do
    quote do
      {CommonLib.Constructor, :required, [{unquote(type), unquote(opts)}]}
    end
  end

  defmacro optional(type) when is_atom(type) do
    quote do
      {CommonLib.Constructor, :optional, [unquote(type)]}
    end
  end

  defmacro optional({type, opts}) when is_atom(type) do
    quote do
      {CommonLib.Constructor, :optional, [{unquote(type), unquote(opts)}]}
    end
  end

  defmacro list_of(type) when is_atom(type) do
    quote do
      {CommonLib.Constructor, :list_of, [unquote(type)]}
    end
  end

  defmacro list_of({type, opts}) when is_atom(type) do
    quote do
      {CommonLib.Constructor, :list_of, [{unquote(type), unquote(opts)}]}
    end
  end

  def optional(value, type)
  def optional(nil, _type), do: {:ok, nil}
  def optional(value, type), do: validate_built_in_type(value, type)

  def required(value, type)
  def required(nil, _type), do: {:error, "cannot be null"}
  def required(value, type), do: validate_built_in_type(value, type)

  def list_of(values, type)
  def list_of(nil, _type), do: {:ok, []}
  def list_of(values, _type) when not is_list(values), do: {:error, "not a list"}

  def list_of([], _type), do: {:ok, []}

  def list_of([value | rest], type) do
    case required(value, type) do
      {:ok, value} ->
        case list_of(rest, type) do
          {:ok, rest} -> {:ok, [value | rest]}
          {:error, error_msg} -> {:error, error_msg}
        end

      {:error, error_msg} ->
        {:error, "element in list " <> error_msg}
    end
  end

  defp validate_built_in_type(value, {type, opts}) do
    case Kernel.apply(BuiltInType, type, [value, opts]) do
      :ok -> {:ok, value}
      {:ok, value} -> {:ok, value}
      {:error, error_msg} -> {:error, error_msg}
    end
  end

  defp validate_built_in_type(value, type) do
    case Kernel.apply(BuiltInType, type, [value]) do
      :ok -> {:ok, value}
      {:ok, value} -> {:ok, value}
      {:error, error_msg} -> {:error, error_msg}
    end
  end
end
