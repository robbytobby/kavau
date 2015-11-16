class ConvertBalancesManuallyEditedToType < ActiveRecord::Migration
  def up
    Balance.all.each do |b|
      b.type = (b.manually_edited ? 'ManualBalance' : 'AutoBalance')
      b.save
    end
  end

  def down
    Balance.all.each do |b|
      b.manually_edited = (b.type == 'ManualBalane' ? true : false)
      b.save
    end
  end
end
