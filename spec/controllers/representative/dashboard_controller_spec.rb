require 'spec_helper'

describe Representative::DashboardController do
  let(:rep) { Representative.make! :confirmed }

  it 'renders the dashboard' do
    sign_in rep

    get :index
    response.should have_rendered(:index)
  end

  it 'does not render the dashboard if unauthorized' do
    get :index
    response.should redirect_to(new_representative_session_path)
  end

end
