defmodule MishkaDeveloperToolsTest.PermissionAccessTest do
  use ExUnit.Case, async: true

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
    "AdminBlogNotifsLive" => "*"
  }

  test "User has PermissionAccess?" do
    result =
      Enum.map(Map.keys(@admin_router), fn item ->
        user_action = [%{value: "*"}]
        PermissionAccess.permittes?(user_action, @admin_router[item])
      end)
      |> Enum.all?()

    assert result

    result1 =
      Enum.map(Map.keys(@admin_router), fn item ->
        user_action = [%{value: "admin:edit"}]
        PermissionAccess.permittes?(user_action, @admin_router[item])
      end)
      |> Enum.all?()

    assert !result1

    assert !PermissionAccess.permittes?(
             [%{value: "admin:blog"}],
             @admin_router["AdminCommentsLive"]
           )

    assert PermissionAccess.permittes?(
             [%{value: "*:edit"}],
             @admin_router["AdminBlogCategoryLive"]
           )
  end
end
