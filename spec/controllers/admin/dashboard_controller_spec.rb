require 'spec_helper'

describe Admin::DashboardController do
  let(:user) { User.make! }
  before { ParliamentSession.make!(start_date: 1.month.ago, end_date: 1.month.from_now) }

  it 'renders the dashboard' do
    sign_in user

    get :index
    response.should have_rendered(:index)
  end

  it 'does not render the dashboard if unauthorized' do
    get :index
    response.should redirect_to(new_user_session_path)
  end

end
