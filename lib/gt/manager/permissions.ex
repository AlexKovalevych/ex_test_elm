defmodule Gt.Manager.Permissions do
    def has(permissions, name, project_id) do
        Enum.any?(permissions, fn {block_k, block_v} ->
            Enum.any?(block_v, fn {node_k, node_v} ->
                (block_k == name or node_k == name) and Enum.member?(node_v, project_id)
            end)
        end)
    end

    def add(permissions, name, project_id) when is_bitstring(name) and is_bitstring(project_id) do
        Enum.reduce(permissions, %{}, fn({block_key, node}, acc) ->
            if block_key == name do
                child = Enum.reduce(node, %{}, fn({k, v}, a) ->
                    Map.put(a, k, insert_project_id(v, project_id))
                end)
                Map.put(acc, block_key, child)
            else
                if Map.has_key?(node, name) do
                    child = put_in(node, [name], insert_project_id(node[name], project_id))
                    Map.put(acc, block_key, child)
                else
                    Map.put(acc, block_key, node)
                end
            end
        end)
    end
    def add(permissions, name, [head | tail]) when is_bitstring(name) do
        add(permissions, name, head) |> add(name, tail)
    end
    def add(permissions, [head | tail], project_id) when is_bitstring(project_id) do
        add(permissions, head, project_id) |> add(tail, project_id)
    end
    def add(permissions, _, []) do
        permissions
    end
    def add(permissions, [], _) do
        permissions
    end
    def add(permissions, [name | name_tail], project_ids) when is_list(project_ids) do
        add(permissions, name, project_ids)
        |> add(name_tail, project_ids)
    end

    defp insert_project_id(projects, project_id) do
        case Enum.member?(projects, project_id) do
            true -> projects
            false -> projects ++ [project_id]
        end
    end

    # def remove(name, project_id, permissions) do
    #     Enum.map(permissions, fn permission ->
    #         if permission.name == name do
    #             Map.update!(permission, :projects, fn v -> List.delete(v, project_id) end)
    #         else
    #             Map.update!(permission, :children, fn children ->
    #                 Enum.map(children, fn child ->
    #                     if child.name == name do
    #                         Map.update!(child, :projects, fn v -> List.delete(v, project_id) end)
    #                     else
    #                         child
    #                     end
    #                 end)
    #             end)
    #         end
    #     end)
    # end
end
