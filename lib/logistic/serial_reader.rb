require 'serialport'

class SerialReader
  
  attr_reader :port
  
  def initialize(dev_port, baud_rate=9600, data_bits=8, stop_bits=1, parity=SerialPort::NONE)
    #super(port, baud_rate, data_bits, stop_bits, parity)
    @port = SerialPort.new(dev_port, baud_rate, data_bits, stop_bits, parity)
  end
  
  def read(delim='*')
    @port.gets(delim).gsub(delim, '')
  end
  
  def close
    @port.close
  end
  
end