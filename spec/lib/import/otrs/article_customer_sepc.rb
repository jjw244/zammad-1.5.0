require 'rails_helper'

RSpec.describe Import::OTRS::ArticleCustomer do

  def load_article_json(file)
    json_fixture("import/otrs/article/#{file}")
  end

  let(:instance_id) { 1337 }
  let(:existing_object) { instance_double(import_object) }
  let(:import_object) { User }
  let(:object_structure) { load_article_json('customer_phone') }
  let(:start_import_test) { described_class.new(object_structure) }

  it 'finds customers by email' do
    expect(import_object).to receive(:find_by).with(email: 'kunde2@kunde.de').and_return(existing_object)
    expect(import_object).not_to receive(:create)
    start_import_test
  end

  it 'finds customers by login' do
    expect(import_object).to receive(:find_by).with(email: 'kunde2@kunde.de')
    expect(import_object).to receive(:find_by).with(login: 'kunde2@kunde.de').and_return(existing_object)
    expect(import_object).not_to receive(:create)
    start_import_test
  end

  it 'creates customers' do
    expect(import_object).to receive(:find_by).at_least(:once)
    expect(import_object).to receive(:create).and_return(existing_object)
    start_import_test
  end

  it 'creates customers with special encoding in name' do
    expect { described_class.new(load_article_json('customer_special_chars')) }.to change { User.count }.by(1)
    expect(User.last.login).to eq('user.hernandez@example.com')
  end

  it 'creates customers with special from email sytax' do
    expect { described_class.new(load_article_json('from_bracket_email_syntax')) }.to change { User.count }.by(1)
    expect(User.last.login).to eq('user@example.com')
  end
end
