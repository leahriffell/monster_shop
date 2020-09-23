require "rails_helper"

RSpec.describe ApplicationHelper, :type => :helper do
  describe "#format_as_percent(num)" do
    it "formats a decimal percent as integer" do
      expect(format_as_percent(0.73)).to eq("73%")
    end
  end
end