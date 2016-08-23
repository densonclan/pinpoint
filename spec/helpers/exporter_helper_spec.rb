require 'spec_helper'

describe ExporterHelper do

  describe 'export_template_fields' do
    specify {
      export_template_fields.should == "Client-Code,Client-Name,Client-Reference,Distribution-Address Business Name,Distribution-Address City,\
Distribution-Address County,Distribution-Address Email,Distribution-Address First Line,Distribution-Address Full Name,Distribution-Address Mobile,\
Distribution-Address Phone Number,Distribution-Address Postcode,Distribution-Address Second Line,Distribution-Address Third Line,Distribution-Address Title,\
Distribution-Contract Number,Distribution-Date Of Distribution,Distribution-Delivery Postcode,Distribution-Distribution Week,Distribution-Leaflet Number,\
Distribution-Notes,Distribution-Publisher,Distribution-Reference Number,Distribution-Ship Via,Distribution-Total Boxes,Distribution-Total Quantity,Distribution-Type,Option-Licenced,\
Option-Multibuy,Option-Name,Option-Price Zone,Option-Reference Number,Option-Total Ambient,Option-Total Licenced,Option-Total Quantity,Option-Total Temp,\
Order-Distribution Week,Order-Status,Order-Total Boxes,Order-Total GH Boxes,Order-Total NEP Boxes,Order-Total Price,Order-Total Quantity,Order-Total Store Boxes,\
Page-Box Quantity,Page-Name,Page-Reference Number,Publisher Address-Business Name,Publisher Address-City,Publisher Address-County,Publisher Address-Email,\
Publisher Address-First Line,Publisher Address-Full Name,Publisher Address-Mobile,Publisher Address-Phone Number,Publisher Address-Postcode,\
Publisher Address-Second Line,Publisher Address-Third Line,Publisher Address-Title,Store Address-Business Name,Store Address-City,Store Address-County,\
Store Address-Email,Store Address-First Line,Store Address-Full Name,Store Address-Mobile,Store Address-Phone Number,Store Address-Postcode,Store Address-Second Line,\
Store Address-Third Line,Store Address-Title,Store-Account Number,Store-Description,Store-Logo,Store-Owner Name,Store-Participation Only,Store-Personalised Address Panel,\
Store-Personalised Panel 1,Store-Personalised Panel 2,Store-Personalised Panel 3,Store-Postcode,Store-Preferred Distribution,Store-Reference Number,Store-Store Urgent"
    }
  end

  describe 'running_order_options' do
    specify {
      running_order_options.should == ["Store Urgents", "Royal Mail 2 weeks prior", "Royal Mail week prior", "Royal Mail week of promo", "Royal Mail week after", 
        "Royal Mail 2 weeks after", "Newspaper 2 weeks prior", "Newspaper week prior", "Newspaper week of promo", "Newspaper week after", "Newspaper 2 weeks after", 
        "Solus Team 2 weeks prior", "Solus Team week prior", "Solus Team week of promo", "Solus Team week after", "Solus Team 2 weeks after", 
        "In Store 2 weeks prior", "In Store week prior", "In Store week of promo", "In Store week after", "In Store 2 weeks after", 
        "Store Own Dist 2 weeks prior", "Store Own Dist week prior", "Store Own Dist week of promo", "Store Own Dist week after", 
        "Store Own Dist 2 weeks after", "Blanks"]
    }
  end
end