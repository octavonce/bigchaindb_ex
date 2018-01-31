defmodule BigchaindbExUtilsTest do
  use BigchaindbEx.TestCase
  alias BigchaindbEx.Utils

  test "divmod/2" do
    assert Utils.divmod(126207244316550804821666916, 256) === {492997048111526581334636, 100}
    assert Utils.divmod(492997048111526581334636, 256) === {1925769719185650708338, 108}
    assert Utils.divmod(1925769719185650708338, 256) === {7522537965568948079, 114}
  end
end