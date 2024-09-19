# frozen_string_literal: true

RSpec.shared_context 'with Rails 4.2', :rails42 do
  let(:rails_version) { 4.2 }
end

RSpec.shared_context 'with Rails 5.0', :rails50 do
  let(:rails_version) { 5.0 }
end

RSpec.shared_context 'with Rails 5.1', :rails51 do
  let(:rails_version) { 5.1 }
end

RSpec.shared_context 'with Rails 5.2', :rails52 do
  let(:rails_version) { 5.2 }
end

RSpec.shared_context 'with Rails 6.0', :rails60 do
  let(:rails_version) { 6.0 }
end

RSpec.shared_context 'with Rails 6.1', :rails61 do
  let(:rails_version) { 6.1 }
end

RSpec.shared_context 'with Rails 7.0', :rails70 do
  let(:rails_version) { 7.0 }
end

RSpec.shared_context 'with Rails 7.1', :rails71 do
  let(:rails_version) { 7.1 }
end

RSpec.shared_context 'with Rails 7.2', :rails72 do
  let(:rails_version) { 7.2 }
end
