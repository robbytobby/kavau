require 'rails_helper'

RSpec.describe "user index" do
  [:user, :accountant].each do |type|
    it "is not available for a #{type}" do
      login_as create(type)
      visit '/users'
      expect(current_path).to eq('/')
    end
  end

  context "as admin" do
    before(:each){login_as create(:admin, name: 'Zoro', login: 'Zoro', email: 'zoro@test.org', phone: 'zoro') }

    describe "is searchable" do
      {name_or_first_name_cont: [:first_name, :name],
       login_cont: [:login],
       email_cont: [:email],
       phone_cont: [:phone]
      }.each_pair do |search, attributes|
        attributes.each do |attr|
          it "by #{attr}" do
            c1 = create :user, attr => ('Albert' + (attr == :email ? '@test.org' : ''))
            c2 = create :user, attr => ('Albrecht' + (attr == :email ? '@test.org' : ''))
            c3 = create :user, attr => ('Xaver' + (attr == :email ? '@test.org' : ''))

            visit '/users'
            fill_in "q_#{search}", with: 'al'
            click_on :suchen
            expect(page).to have_css("tr#user_#{c1.id}")
            expect(page).to have_css("tr#user_#{c2.id}")
            expect(page).not_to have_css("tr#user_#{c3.id}")
          end
        end
      end

      it "by country_role" do
        c1 = create :user, role: :accountant 
        c2 = create :user, role: :user
        c3 = create :user, role: :accountant 

        visit '/users'
        select 'Buchhalter_in', from: 'q_role_eq'
        click_on :suchen
        expect(page).to have_css("tr#user_#{c1.id}")
        expect(page).to_not have_css("tr#user_#{c2.id}")
        expect(page).to have_css("tr#user_#{c3.id}")
      end

      it "is paginated" do
        create_list :user, 15, name: 'Albert' 
        create_list :user, 13, name: 'Berta' 
        create_list :user, 3, name: 'Charlie' 

        visit '/users'
        expect(page).to have_content('Albert', count: 15 )
        expect(page).to_not have_content('Berta')
        expect(page).to_not have_content('Charlie')

        click_on :next
        expect(page).to_not have_content('Albert')
        expect(page).to have_content('Berta', count: 13)
        expect(page).to have_content('Charlie', count: 2)

        click_on :next
        expect(page).to_not have_content('Albert')
        expect(page).not_to have_content('Berta')
        expect(page).to have_content('Charlie', count: 1)
      end

      describe "is sortable" do
        it "default sort is name ascending" do
          c1 = create :user, name: 'Xaver' 
          c2 = create :user, name: 'Berta'
          c3 = create :user, name: 'Oleg'

          visit '/users'
          expect(page).to have_css("tr#user_#{c1.id}:nth-child(3)")
          expect(page).to have_css("tr#user_#{c2.id}:nth-child(1)")
          expect(page).to have_css("tr#user_#{c3.id}:nth-child(2)")
        end

        {name: 'Name', login: 'Login', email: 'Email', phone: 'Telefon'}.each_pair do |attr, name|
          it "is resortable by #{attr}" do
            c1 = create :user, attr => ('Berta' + (attr == :email ? '@test.org' : ''))
            c2 = create :user, attr => ('Albrecht' + (attr == :email ? '@test.org' : ''))
            c3 = create :user, attr => ('Xaver' + (attr == :email ? '@test.org' : ''))

            visit users_path(q: {s: ''})
            click_on name
            expect(page).to have_css("tr#user_#{c1.id}:nth-child(2)")
            expect(page).to have_css("tr#user_#{c2.id}:nth-child(1)")
            expect(page).to have_css("tr#user_#{c3.id}:nth-child(3)")

            click_on name
            #beware of loged_in admin named zoro
            expect(page).to have_css("tr#user_#{c1.id}:nth-child(3)")
            expect(page).to have_css("tr#user_#{c2.id}:nth-child(4)")
            expect(page).to have_css("tr#user_#{c3.id}:nth-child(2)")
          end
        end
      end
    end
  end
end
