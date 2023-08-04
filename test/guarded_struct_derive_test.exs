defmodule MishkaDeveloperToolsTest.GuardedStructDeriveTest do
  use ExUnit.Case, async: true
  alias MishkaDeveloperTools.Helper.Derive.{SanitizerDerive, ValidationDerive}

  ############## (▰˘◡˘▰) Sanitizer Derive (▰˘◡˘▰) ##############
  test "sanitize(:trim, input)" do
    "Mishka Group" = assert SanitizerDerive.sanitize(:trim, "  Mishka Group  ")
  end

  test "sanitize(:upcase, input)" do
    "MISHKA GROUP" = assert SanitizerDerive.sanitize(:upcase, "Mishka Group")
  end

  test "sanitize(:downcase, input)" do
    "mishka group" = assert SanitizerDerive.sanitize(:downcase, "MISHKA GROUP")
  end

  test "sanitize(:capitalize, input)" do
    "Mishka group" = assert SanitizerDerive.sanitize(:capitalize, "mishka group")
  end

  test "sanitize(:basic_html, input)" do
    "<p>Hi Shahryar</p>" = assert SanitizerDerive.sanitize(:basic_html, "<p>Hi Shahryar</p>")
  end

  test "sanitize(:html5, input)" do
    "<section>Hi Shahryar</section>" =
      assert SanitizerDerive.sanitize(:html5, "<section>Hi Shahryar</section>")
  end

  test "sanitize(:markdown_html, input)" do
    "[Mishka Group](https://mishka.group)" =
      assert SanitizerDerive.sanitize(:markdown_html, "[Mishka Group](https://mishka.group)")
  end

  test "sanitize(:strip_tags, input)" do
    "Hi Shahryar" = assert SanitizerDerive.sanitize(:strip_tags, "<p>Hi Shahryar</p>")
  end

  ############## (▰˘◡˘▰) Validation Derive (▰˘◡˘▰) ##############
  test "" do
  end
end
