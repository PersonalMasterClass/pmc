class PresentersSubjects < ActiveRecord::Migration
  def change
  	create_table :presenters_subjects, id: false do |t|
  		t.belongs_to :presenter, index: true
  		t.belongs_to :subject, index: true
  	end
  end
end
