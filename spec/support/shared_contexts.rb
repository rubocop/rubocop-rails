# frozen_string_literal: true

RSpec.shared_context 'with Rails 3', :rails3 do
  let(:rails_version) { 3.0 }
end

RSpec.shared_context 'with Rails 4', :rails4 do
  let(:rails_version) { 4.0 }
end

RSpec.shared_context 'with Rails 5', :rails5 do
  let(:rails_version) { 5.0 }
end
