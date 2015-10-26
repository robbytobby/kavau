require 'rails_helper'

RSpec.describe "creditors index view" do
  context "as an unpriviledged user" do
    before(:each){ login_as create(:user) }

    it "is not possible do acces the creditors index" do
      visit '/creditors'
      expect(current_path).to eq('/')
    end
  end

  context "as an accountant" do
    before(:each){ login_as create(:accountant) }

    ['person', 'organization'].each do |type|
      it "shows all #{type.pluralize}" do
        @address = create type.to_sym
        visit '/creditors'
        expect(page).to have_selector("tr##{type}_#{@address.id}")
      end

      it "is possible to show all #{type.pluralize}" do
        @address = create type.to_sym, email: 'test@test.org', phone: 'number'
        visit '/creditors'
        click_on "show_#{@address.id}"
        expect(current_path).to eq(send("#{type}_path", @address))
        click_on 'back'
        expect(current_path).to eq(creditors_path)
      end
    
      it "is possible to edit all #{type.pluralize}" do
        @address = create type.to_sym
        visit '/creditors'
        click_on "edit_#{type}_#{@address.id}"
        expect(current_path).to eq(send("edit_#{type}_path", @address))
      end

      it "is possible to create a #{type}" do
        visit creditors_path
        click_on "add_#{type}"
        expect(current_path).to eq(send("new_#{type}_path"))
      end

      it "shows notes in a popover" do
        @address = create type.to_sym, notes: 'NOTES'
        visit '/creditors'
        expect(page).to have_css("span[data-content='NOTES']")
      end
    end

    describe "it is searchable" do
      {name_or_first_name_cont: [:first_name, :name],
       street_number_cont: [:street_number],
       zip_or_city_cont: [:zip, :city]
      }.each_pair do |search, attributes|
        attributes.each do |attr|
          it "by #{attr}" do
            c1 = create :person, attr => 'Albert'
            c2 = create :organization, attr => 'Albrecht'
            c3 = create :person, attr => 'Zoro'

            visit '/creditors'
            fill_in "q_#{search}", with: 'al'
            click_on :suchen
            expect(page).to have_css("tr#person_#{c1.id}")
            expect(page).to have_css("tr#organization_#{c2.id}")
            expect(page).not_to have_css("tr#person_#{c3.id}")
          end
        end
      end

      it "by country_code" do
        c1 = create :person, country_code: 'DE'
        c2 = create :organization, country_code: 'DE'
        c3 = create :person, country_code: 'FR'

        visit '/creditors'
        select 'Deutschland', from: 'q_country_code_eq'
        click_on :suchen
        expect(page).to have_css("tr#person_#{c1.id}")
        expect(page).to have_css("tr#organization_#{c2.id}")
        expect(page).not_to have_css("tr#person_#{c3.id}")
      end
    end

    it "is paginated" do
      create_list :person, 15, name: 'Albert'
      create_list :organization, 17, name: 'BASF'
      create_list :person, 3, name: 'Dubel'

      visit '/creditors'
      expect(page).to have_content('Albert', count: 15 )
      expect(page).to_not have_content('BASF')
      expect(page).to_not have_content('Dubel')

      click_on :next
      expect(page).to_not have_content('Albert')
      expect(page).to have_content('BASF', count: 15)
      expect(page).to_not have_content('Dubel')

      click_on :next
      expect(page).to_not have_content('Albert')
      expect(page).to have_content('BASF', count: 2)
      expect(page).to have_content('Dubel', count: 3)
    end

    describe "it is sortable" do
      it "default is name asc" do
        c1 = create :person, name: 'Zoro' 
        c2 = create :organization, name:  'Berta'
        c3 = create :person, name: 'Oleg'

        visit '/creditors'
        expect(page).to have_css("tr#person_#{c1.id}:nth-child(3)")
        expect(page).to have_css("tr#organization_#{c2.id}:nth-child(1)")
        expect(page).to have_css("tr#person_#{c3.id}:nth-child(2)")
      end

      {name: 'Name', street_number: 'Straße & Nr', city: 'Stadt'}.each_pair do |attr, name|
        it "is resortable by #{attr}" do
          c1 = create :person, attr => 'Zoro' 
          c2 = create :organization, attr => 'Berta'
          c3 = create :person, attr => 'Oleg'

          visit creditors_path(q: {s: ''})
          click_on name
          expect(page).to have_css("tr#person_#{c1.id}:nth-child(3)")
          expect(page).to have_css("tr#organization_#{c2.id}:nth-child(1)")
          expect(page).to have_css("tr#person_#{c3.id}:nth-child(2)")

          click_on name
          expect(page).to have_css("tr#person_#{c1.id}:nth-child(1)")
          expect(page).to have_css("tr#organization_#{c2.id}:nth-child(3)")
          expect(page).to have_css("tr#person_#{c3.id}:nth-child(2)")
        end
      end
    end
  end
end
