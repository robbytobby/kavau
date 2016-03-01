class KavauDeviseMailerPreview < ActionMailer::Preview
  def reset_password_instructions
    KavauDeviseMailer.reset_password_instructions(User.first, "faketoken", {})
  end
end
