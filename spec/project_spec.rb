# frozen_string_literal: true

RSpec.describe 'RuboCop Rails Project', type: :feature do
  describe 'changelog' do
    subject(:changelog) do
      path = File.join(File.dirname(__FILE__), '..', 'CHANGELOG.md')
      File.read(path)
    end

    let(:lines) { changelog.each_line }

    let(:non_reference_lines) do
      lines.take_while { |line| !line.start_with?('[@') }
    end

    it 'has newline at end of file' do
      expect(changelog.end_with?("\n")).to be true
    end

    it 'has either entries, headers, or empty lines' do
      expect(non_reference_lines).to all(match(/^(\*|#|$)/))
    end

    it 'has link definitions for all implicit links' do
      implicit_link_names = changelog.scan(/\[([^\]]+)\]\[\]/).flatten.uniq
      implicit_link_names.each do |name|
        expect(changelog.include?("[#{name}]: http"))
          .to be(true), "CHANGELOG.md is missing a link for #{name}. " \
                        'Please add this link to the bottom of the file.'
      end
    end

    describe 'entry' do
      subject(:entries) { lines.grep(/^\*/).map(&:chomp) }

      it 'has a whitespace between the * and the body' do
        expect(entries).to all(match(/^\* \S/))
      end

      context 'after version 0.14.0' do
        let(:lines) do
          changelog.each_line.take_while do |line|
            !line.start_with?('## 0.14.0')
          end
        end

        it 'has a link to the contributors at the end' do
          expect(entries).to all(match(/\(\[@\S+\]\[\](?:, \[@\S+\]\[\])*\)$/))
        end
      end

      describe 'link to related issue' do
        let(:issues) do
          entries.map do |entry|
            entry.match(/\[(?<number>[#\d]+)\]\((?<url>[^\)]+)\)/)
          end.compact
        end

        it 'has an issue number prefixed with #' do
          issues.each do |issue|
            expect(issue[:number]).to match(/^#\d+$/)
          end
        end

        it 'has a valid URL' do
          issues.each do |issue|
            number = issue[:number].gsub(/\D/, '')
            pattern = %r{^https://github\.com/rubocop-hq/rubocop-rails/(?:issues|pull)/#{number}$} # rubocop:disable Metrics/LineLength
            expect(issue[:url]).to match(pattern)
          end
        end

        it 'has a colon and a whitespace at the end' do
          entries_including_issue_link = entries.select do |entry|
            entry.match(/^\*\s*\[/)
          end

          expect(entries_including_issue_link).to all(include('): '))
        end
      end

      describe 'contributor name' do
        subject(:contributor_names) { lines.grep(/\A\[@/).map(&:chomp) }

        it 'has a unique contributor name' do
          expect(contributor_names.uniq.size).to eq contributor_names.size
        end
      end

      describe 'body' do
        let(:bodies) do
          entries.map do |entry|
            entry
              .gsub(/`[^`]+`/, '``')
              .sub(/^\*\s*(?:\[.+?\):\s*)?/, '')
              .sub(/\s*\([^\)]+\)$/, '')
          end
        end

        it 'does not start with a lower case' do
          bodies.each do |body|
            expect(body).not_to match(/^[a-z]/)
          end
        end

        it 'ends with a punctuation' do
          expect(bodies).to all(match(/[\.\!]$/))
        end
      end
    end
  end
end
