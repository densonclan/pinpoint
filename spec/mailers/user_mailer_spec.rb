require "spec_helper"

describe UserMailer do

  describe 'require_activation_email' do
    before do
      user = double('User', name: 'Jonno', email: 'jonathon@arctickiwi.com', id: 13)
      @email = UserMailer.require_activation_email(user)
    end

    let(:admins) do
      %w( alan.richards@gaskandhawley.com gary.hunter@gaskandhawley.com
        george.swain@gaskandhawley.com matt@sourcelab.technology )
    end

    specify { @email.to.sort.should == admins }
    specify { @email.from.should == ['pinpoint@gaskandhawley.com'] }
    specify { @email.subject.should == "A new Pinpoint user requires activation" }
    specify { @email.body.encoded.should match('Jonno') }
    specify { @email.body.encoded.should match('jonathon@arctickiwi.com') }
    specify { @email.body.encoded.include?(users_url(id: 13)).should be_true }
  end

  describe 'user_activated_email' do
    before { @email = UserMailer.user_activated_email(double('User', name: 'Jonno', email: 'jonathon@arctickiwi.com')) }
    specify { @email.to.should == ['jonathon@arctickiwi.com'] }
    specify { @email.from.should == ['pinpoint@gaskandhawley.com'] }
    specify { @email.subject.should == "Your Pinpoint account has been activated" }
    specify { @email.body.encoded.should match('Jonno') }
    specify { @email.body.encoded.include?(root_url).should be_true }
  end
end