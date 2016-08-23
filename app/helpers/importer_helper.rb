module ImporterHelper

  def import_class_options
  	if current_user.courier?
    	[['Proof Of Delivery','ProofOfDelivery']]
    else
    	[['Orders','Order'],['Stores','Store'],['Business Managers','BusinessManager'],['Addresses','Address'],['Periods','Period'],['Distributors','Distributor'],['Clients','Client'],['Options','Option'],['Pages','Page'],['Logotypes','Logotype'],['Notes','Comment'],['Big Trev','PostcodeSector'],['Proof Of Delivery','ProofOfDelivery']]
    end
  end

  def can_cancel_import?(transport)
    transport.pending? || transport.working?
  end
end
