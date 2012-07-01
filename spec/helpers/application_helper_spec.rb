require 'spec_helper'

describe ApplicationHelper do
    context "representative_carousel_content" do
      it "should group array into subarrays" do
        array = [1,2,3,4,5,6,7,8]
        get_representative_carousel_content(array).should == [[1,2,3,4], [5,6,7,8]]
      end
    end                                                                                
end
