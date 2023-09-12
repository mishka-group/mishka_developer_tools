defmodule PermissionAccess do
  @moduledoc """
    Consider the scenario in which you are responsible for maintaining each user's access
    level in the database related to users. In addition, each router in your controller needs
    to be free for one access while preventing other things from accessing it. To achieve
    this goal, the PermissionAccess module provides assistance in implementing a Unix-like mode
    in the most straightforward manner feasible.
    This module was written with the contribution of Mr. Toomaj Boloorian,
    who can be found at the following GitHub address: https://github.com/toomaj
    and and Shahryar Tavakkoli: https://github.com/shahryarjb
  """
  @separator ":"

  @type action() :: String.t()
  @type user_permissions() :: list(String.t())

  @doc """
  ### Allow access to the user

  Access in this section is referred to as an action, and in addition, there are two sections included.

  The first portion may grant access to an entire department or to an entire role, whereas the second part
  may be delegated to a specific part. But this explanation is subject to alter depending on the strategy
  you choose. Because of this, pay close attention to the instances that follow.

  Within this section, the user has access to all portions of your program thanks to the wildcard permissions that have been granted to him.

  **Note**: You have the option of assigning a star `*` rating or writing it as `*:*`.

  ```elixir
  @admin_router %{
    # admin router
    "AdminDashboardLive" => "admin:*",
    "AdminBlogPostsLive" => "admin:edit",
    "AdminBlogPostLive" => "admin:edit",
    "AdminBlogCategoriesLive" => "admin:edit",
    "AdminBlogCategoryLive" => "admin:edit",
    "AdminBookmarksLive" => "*",
    "AdminSubscriptionsLive" => "*",
    "AdminSubscriptionLive" => "*",
    "AdminCommentsLive" => "admin:edit",
    "AdminCommentLive" => "admin:edit",
    "AdminUsersLive" => "*",
    "AdminUserLive" => "*",
    "AdminLogsLive" => "*",
    "AdminSeoLive" => "*",
    "AdminBlogPostAuthorsLive" => "admin:edit",
    "AdminBlogNotifLive" => "*",
    "AdminBlogNotifsLive" => "admin:view"
  }

  user_actions = [%{value: "*"}]
  PermissionAccess.permittes?(user_actions, @admin_router[item])
  # This should be true, and the user has access.

  user_actions = [%{value: "*:edit"}]
  PermissionAccess.permittes?(user_actions, @admin_router["AdminBlogNotifsLive"])
  # This should be false, and the user has no access.

  user_actions = [%{value: "*:edit"}, %{value: "admin:view"}]
  PermissionAccess.permittes?(user_actions, @admin_router["AdminBlogNotifsLive"])
  # This should be true, and the user has access.
  ```
  """
  @spec permittes?(user_permissions(), action()) :: boolean
  def permittes?(user_permissions, action) do
    Enum.any?(
      user_permissions,
      fn %{value: permission} ->
        is_permitted?(action: action, permission: permission)
      end
    )
  end

  @doc """
   This section is identical to the function known as `permittes?/2`, with the exception that
   it examines only a single user access rather than a list of accesses.

   ```elixir
  PermissionAccess.is_permitted?(action: "*", @admin_router["AdminBlogNotifsLive"])
   ```
  """
  @spec is_permitted?([{:action, action()} | {:permission, binary}]) :: boolean
  def is_permitted?(action: action, permission: permission) do
    permission_chunks = String.split(permission, @separator)

    String.split(action, @separator, parts: length(permission_chunks))
    |> check_permission(permission_chunks)
  end

  defp check_permission(action_chunks, permission_chunks)
       when length(permission_chunks) != length(action_chunks),
       do: false

  defp check_permission(action_chunks, permission_chunks) do
    Enum.zip(permission_chunks, action_chunks)
    |> Enum.find(fn {left, right} ->
      cond do
        left == "*" -> false
        left != right -> true
        true -> false
      end
    end)
    |> is_nil()
  end
end
