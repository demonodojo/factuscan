# == Schema Information
#
# Table name: invoices
#
#  id           :bigint           not null, primary key
#  invoice_date :date
#  ocr_data     :jsonb
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require "test_helper"

class InvoiceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
