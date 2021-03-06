defmodule Gt.Model.Project do
    use Gt.Web, :model

    @derive {Poison.Encoder, only: [:id, :title, :prefix, :item_id, :url, :enabled, :isPoker, :isPartner]}

    @collection "projects"

    schema @collection do
        field :title, :string
        field :prefix, :string
        field :item_id, :string
        field :external_id, :string
        field :url, :string
        field :logoUrl, :string
        field :enabled, :boolean
        field :currency_rate, :float
        field :isPoker, :boolean, default: false
        field :games, {:array, :string}
        field :base_amount, :string
        field :isPartner, :boolean, default: false
    end

    @required_fields ~w(title prefix item_id url enabled external_id)
    @optional_fields ~w(logoUrl currency_rate isPoker games base_amount isPartner)

    def changeset(model, params \\ :empty) do
        model
        |> cast(params, @required_fields, @optional_fields)
        # TODO: in ecto 2.0 replace with validate_required
        |> validate_length(:title, min: 1, message: "validation.not_blank")
        |> validate_length(:prefix, min: 1, message: "validation.not_blank")
        |> validate_length(:item_id, min: 1, message: "validation.not_blank")
        |> validate_length(:url, min: 1, message: "validation.not_blank")
        |> unique_constraint(:item_id, message: "Project with this item_id already exists")
    end

    def ids(query, project_ids) do
        from u in query,
        where: u.id in ^project_ids
    end

    def get_ids(query) do
        from u in query,
        select: u.id
    end

    def titles(query, titles) when is_list(titles) do
        from u in query,
        where: u.title in ^titles
    end
    def titles(query, title) when is_bitstring(title) do
        from u in query,
        where: u.title == ^title
    end

    def prefix(query, prefix) do
        from u in query,
        where: u.prefix == ^prefix
    end

    def filter_by_title(query, search) do
        regex = Mongo.Ecto.Helpers.regex(".*#{search}.*", "i")
        from u in query,
        where: fragment(title: ^regex),
        order_by: u.title
    end

    def page(query, page_number, limit \\ 10) do
        from u in query,
        limit: ^limit,
        offset: ^(limit * (page_number - 1))
    end

    def count(query) do
        from u in query,
        select: count(u.id)
    end
end
