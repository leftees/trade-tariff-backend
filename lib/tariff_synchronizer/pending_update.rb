module TariffSynchronizer
  class PendingUpdate
    attr_reader :update,
                :file_name

    delegate :apply, :issue_date, :update_priority, to: :update

    def initialize(update)
      @file_name = update.filename
      @update = update
    end

    def self.all
      BaseUpdate.pending.all.map { |update| new(update) }
    end

    def to_s
      file_name
    end
  end
end
