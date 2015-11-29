require 'rails_helper'

RSpec.describe "Letters" do
  [:admin, :accountant].each do |type|
    context "as #{type}" do
      before(:each){ login_as create(type) }

      it "has a index page" do
        visit '/'
        click_on :letters_index
        expect(current_path).to eq(letters_path)
      end

      [:standard_letters, :balance_letters, :termination_letters].each do |letter_type|
        context "#{letter_type}" do
          let(:singular){ letter_type.to_s.singularize }

          it "I can create new #{letter_type}" do
            visit '/letters'
            click_on "add_#{letter_type.to_s.singularize}"
            expect(current_path).to eq("/#{letter_type}/new")
            fill_in "#{singular}_subject", with: 'Subject'
            fill_in "#{singular}_content", with: 'Text of Letter'
            fill_in "#{singular}_year", with: '2013' if letter_type == :balance_letters
            click_on :submit
            expect(current_path).to eq("/#{letter_type}/#{Letter.last.id}")
            expect(page).to have_selector('div.alert-notice')
          end

          it "I can cancel creating a new #{letter_type}" do
            visit '/letters'
            click_on "add_#{letter_type.to_s.singularize}"
            click_on :cancel
            expect(current_path).to eq("/letters")
          end

          it "I can edit a #{letter_type}" do
            letter = create singular
            visit '/letters'
            click_on "edit_#{singular}_#{letter.id}"
            expect(current_path).to eq(send("edit_#{singular}_path", letter))
            fill_in "#{singular}_content", with: 'New Text'
            click_on :submit
            expect(current_path).to eq("/#{letter_type}/#{letter.id}")
            expect(page).to have_selector('div.alert-notice')
          end

          it "I can delete a #{letter_type}" do
            letter = create singular
            visit '/letters'
            click_on "delete_#{singular}_#{letter.id}"
            expect(current_path).to eq('/letters')
            expect(page).not_to have_selector("tr##{singular}_#{letter.id}")
          end

          it "I see delete, edit and back to index links on the show page" do
            letter = create singular
            visit "#{letter_type}/#{letter.id}"
            expect(page).to have_selector("a#back[href='/letters']")
            expect(page).to have_selector("a#edit[href='/#{letter_type}/#{letter.id}/edit']")
            expect(page).to have_selector("a#destroy[href='/#{letter_type}/#{letter.id}']")
          end
        end
      end
    end
  end
end
