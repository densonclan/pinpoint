require "spec_helper"

describe MessageMailer do
  describe 'message_notification' do
  	let(:user) { FactoryGirl.create(:user) }
  	let(:message) { FactoryGirl.create(:message, :user => user, :receiver => user) }
  	let(:mail) { MessageMailer.message_notification(message) }

  	# Ensure the subject includes sender's name
  	it 'renders the subject' do
  		mail.subject.should == "[PinPoint] New message notification from #{user.name}"
  	end

  	# Ensure that the message is send to the receiver
  	it 'renders the receiver email' do
  		mail.to.should == [message.receiver.email]
  	end

    # Ensure that the sender is correct
    it 'renders the sender email' do
      mail.from.should == ['pinpoint@gaskandhawley.com']
    end

    # Ensure that the @name variable appears in the email body
    it 'assigns @name' do
      mail.body.encoded.should match(message.user.name)
    end

    # Ensure that the @message variable appears in the email body
    it 'assigns @message_url' do
      mail.body.encoded.should match("http://www.pinpointlms.co.uk/messages/#{message.id}")
    end

  end
end
