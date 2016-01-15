FactoryGirl.define do
  factory :letter do
    type 'Letter'
    subject 'Letter Subject'
    content 'Letter content'
  end

  factory :termination_letter, class: TerminationLetter do
    type 'TerminationLetter'
    content 'Termination content'
  end

  factory :payment_letter, class: PaymentLetter do
    type 'PaymentLetter'
    content 'payment content'
  end

  factory :balance_letter, class: BalanceLetter do
    type 'BalanceLetter'
    content 'Balance content'
    year '2014'
  end

  factory :standard_letter, class: StandardLetter do
    type 'StandardLetter'
    subject 'News'
    content 'Very important news'
  end
end
