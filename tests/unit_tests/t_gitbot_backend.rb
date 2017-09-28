#! /usr/bin/ruby

require_relative 'helper'

Dir.chdir Dir.pwd
# Test the option parser
class BackendTest2 < Minitest::Test
  def setup
    @full_hash = { repo: 'gino/gitbot', context: 'python-t', description:
                   'functional', test_file: 'gino.sh', file_type: '.sh',
                   git_dir: 'gitty', change_newer: -1 }
  end

  def test_full_option_import2
    gitbot = Backend.new(@full_hash)
    puts gitbot.j_status
    gitbot.j_status = 'foo'
    gitbot_assert(gitbot)
  end

  def gitbot_assert(gitbot)
    assert_equal('gino/gitbot', gitbot.repo)
    assert_equal('python-t', gitbot.context)
    assert_equal('functional', gitbot.description)
    assert_equal('gino.sh', gitbot.test_file)
    assert_equal('.sh', gitbot.file_type)
    assert_equal('gitty', gitbot.git_dir)
  end

  def test_run_script
    @full_hash[:test_file] = 'test_data/script_ok.sh'
    gbex = TestExecutor.new(@full_hash)
    ck_files(gbex)
    test_file = 'nofile.txt'
    assert_file_non_ex(gbex, test_file)
  end

  def ck_files(gbex)
    assert_equal('success', gbex.run_script)
    gbex.test_file = 'test_data/script_fail.sh'
    assert_equal('failure', gbex.run_script)
  end

  def assert_file_non_ex(gbex, test_file)
    ex = assert_raises RuntimeError do
      gbex.test_file = test_file
      gbex.run_script
    end
    assert_equal("'#{test_file}\' doesn't exists.Enter valid file, -t option",
                 ex.message)
  end

  def test_get_all_prs
    @full_hash[:repo] = 'openSUSE/gitbot'
    gitbot = Backend.new(@full_hash)
    prs = gitbot.open_newer_prs
    assert(true, prs.any?)
  end

  def test_get_no_prs
    @full_hash[:repo] = 'openSUSE/gitbot'
    @full_hash[:change_newer] = 0
    gitbot = Backend.new(@full_hash)
    prs = gitbot.open_newer_prs
    assert(0, prs.count)
  end
end
