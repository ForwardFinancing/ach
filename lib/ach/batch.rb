module ACH
  class Batch
    attr_reader :entries
    attr_reader :header
    attr_reader :control
    
    def initialize
      @entries = []
      @header = Records::BatchHeader.new
      @control = Records::BatchControl.new
    end
    
    def to_ach
      @control.entry_count = @entries.length
      @control.debit_total = 0
      @control.credit_total = 0
      @control.entry_hash = 0
      
      @entries.each do |e|
        if e.debit?
          @control.debit_total += e.amount
        else
          @control.credit_total += e.amount
        end
        @control.entry_hash +=
            (e.routing_number.to_i / 10) # Last digit is not part of Receiving DFI
      end
      
      @control.company_identification = @header.company_identification
      @control.originating_dfi_identification = @header.originating_dfi_identification
      @control.batch_number = @header.batch_number
      
      [@header] + @entries + [@control]
    end
  end
end