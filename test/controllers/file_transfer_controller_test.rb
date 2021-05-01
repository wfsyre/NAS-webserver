require "test_helper"

class FileTransferControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get file_transfer_show_url
    assert_response :success
  end
end
