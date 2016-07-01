defmodule Gt.Model do
    defmacro __using__(_) do
        quote do
            use Ecto.Model
            @primary_key {:id, :binary_id, autogenerate: true}
            # @foreign_key_type :string # For associations
        end
    end
end
