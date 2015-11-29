FactoryGirl.define do
  factory :letter do
    type 'Letter'
    subject 'Letter Subject'
    content 'Letter content'
  end

  factory :termination_letter, class: TerminationLetter do
    type 'TerminationLetter'
    subject 'Termination of credit agreemnet'
    content 'Termination content'
  end

  factory :balance_letter, class: BalanceLetter do
    type 'BalanceLetter'
    subject 'Termination of credit agreemnet'
    content 'Termination content'
  end

  factory :standard_letter, class: StandardLetter do
    type 'StandardLetter'
    subject 'News'
    content 'Very important news'
  end
end
