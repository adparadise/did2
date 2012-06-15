class Did::Git
  def initialize(did)
    @did = did
  end

  def sync
    commit
    pull
    push
  end

  def commit
    diffed_files
  end
  
  def pull

  end

  def push

  end

  private

  def diffed_files
    list = `cd #{@did.home.to_s} && git diff | grep +++`
    puts list
  end
  
end
