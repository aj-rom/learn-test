# frozen_string_literal: true

describe LearnTest::Git::Wip::Base do
  describe 'attr_reader' do
    let(:base) { LearnTest::Git::Base.open('./') }
    let(:message) { 'foobar' }
    let(:instance) do
      described_class.new(
        base: base,
        message: message
      )
    end

    it 'should have :working_branch, :wip_branch' do
      expect(instance).to respond_to(:working_branch, :wip_branch)
    end
  end

  describe '.process!', type: :aruba do
    let!(:path) { File.join Aruba.config.home_directory, 'example' }
    let(:base) { LearnTest::Git::Base.open(path) }
    let(:message) { 'foobar' }
    let(:instance) do
      described_class.new(
        base: base,
        message: message
      )
    end

    def initialize_repo(commit: true)
      create_directory 'example'
      cd 'example'
      write_file 'README.md', 'Hello World'
      run_command_and_stop 'git init'

      if commit
        run_command_and_stop 'git add .'
        run_command_and_stop 'git commit -m "Initial Commit"'
      end
    end

    context 'no commits' do
      before(:each) { initialize_repo(commit: false) }

      it 'should raise' do
        expect { instance.process! }.to raise_error(LearnTest::Git::Wip::NoCommitsError)
      end
    end

    xcontext 'no changes' do
      before(:each) { initialize_repo }

      it 'should raise' do
        expect { instance.process! }.to raise_error(LearnTest::Git::Wip::NoChangesError)
      end
    end

    context 'changes' do
      context 'staged' do
        before :each do
          initialize_repo
          write_file 'test.rb', ''
        end

        it 'should process successfully' do
          instance.process!

          expect(instance.success?).to eq(true)
        end
      end

      context 'committed' do
        before :each do
          initialize_repo
          write_file 'test.rb', ''

          run_command_and_stop 'git add .'
          run_command_and_stop 'git commit -m "foo"'
        end

        it 'should process successfully' do
          instance.process!

          expect(instance.success?).to eq(true)
        end
      end
    end
  end
end

