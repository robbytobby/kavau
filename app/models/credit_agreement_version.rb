class CreditAgreementVersion < PaperTrail::Version
  self.table_name = :credit_agreement_versions
  self.sequence_name = :credit_agreement_versions_id_seq
end
