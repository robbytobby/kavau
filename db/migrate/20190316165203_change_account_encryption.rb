class ChangeAccountEncryption < ActiveRecord::Migration[5.2]
  class MigratAccountCrypto < ActiveRecord::Base
    self.table_name = 'accounts'
  
    [:name, :bic, :iban, :bank, :owner].each do |attr|
      attr_encrypted attr, 
        key: Proc.new{ |account| account.key_toggle(attr) },
        mode: Proc.new{ |account| account.mode_toggle(attr) },
        algorithm: Proc.new{ |account| account.algorithm_toggle(attr) },
        insecure_mode: Proc.new{ |account| account.is_decrypting?(attr) }
    end
  
    def is_decrypting?(attribute)
      encrypted_attributes[attribute][:operation] == :decrypting
    end
  
    def key_toggle(attribute)
      if is_decrypting?(attribute)
        puts Rails.application.config.kavau_encryption_key
        Rails.application.config.kavau_encryption_key
      else
        puts Rails.application.config.new_kavau_encryption_key
        Base64.decode64(Rails.application.config.new_kavau_encryption_key)
      end
    end
  
    def mode_toggle(attribute)
      if is_decrypting?(attribute)
        :per_attribute_iv_and_salt
      else
        :per_attribute_iv
      end
    end
  
    def algorithm_toggle(attribute)
      if is_decrypting?(attribute)
        'aes-256-cbc'
      else
        'aes-256-gcm'
      end
    end
  
  end

  def up
    MigratAccountCrypto.all.each do |account|
      [:name, :bic, :iban, :bank, :owner].each do |attr|
        old_attr = account.send(attr)
        account.send("#{attr}=", old_attr)
      end
      account.save
    end
  end
end
