require 'spec_helper'

describe ApplicationHelper do
  it 'obscures email addresses' do
    helper.obscure_email('foo@bar.com').should == "&#102;&#111;&#111;&#0064;&#98;&#97;&#114;.&#99;&#111;&#109;"
  end

  it 'truncates sentences' do
    lorem     = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
    truncated = helper.awesome_truncate(lorem, 250)

    truncated.should == "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure..."
  end

  it 'renders markdown' do
    md = <<-MARKDOWN
# foo

*bar*
    MARKDOWN

    helper.markdown(md).should == "<h1>foo</h1>\n\n<p><em>bar</em></p>\n"
  end
end
