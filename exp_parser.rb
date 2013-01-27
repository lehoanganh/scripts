# @author: me[at]lehoanganh[dot]de

# used to parse experiment results to retrieve the needed information

require 'logger'
require 'csv'

logger = Logger.new(STDOUT)
logger.info '-----------------------------------------------------------------'
logger.info 'Welcome!'
logger.info 'The script will scan all experiment results in the current folder'
logger.info 'and save the parsed information in results.csv'
logger.info '-----------------------------------------------------------------'

logger.info '-----------------------------------------------------------------'
logger.info 'The current directory contains following experiment result files:'
logger.info '-----------------------------------------------------------------'
Dir.glob("*.dat") do |exp|
  puts exp
end

logger.info 'ITERATING...'
cur_dir = Dir.getwd

Dir.glob("*.dat") do |exp|
  logger.info '-----------------------------------------------------------------'
  logger.info "File: #{exp}"
  logger.info '-----------------------------------------------------------------'
  
  # parsing file name
  tmp_arr = []
  tmp_arr << exp.to_s.byteslice(0,2) # experiment number
  if exp.to_s.include? 'load' # loading phase or transaction phase
    tmp_arr << 'load'
  else  
    tmp_arr << 'run'
  end
  if exp.to_s.include? '_a' # workload file
    tmp_arr << 'a'
  elsif exp.to_s.include? '_b'
    tmp_arr << 'b'
  elsif exp.to_s.include? '_c'
    tmp_arr << 'c'
  else
    tmp_arr << 'undefined'      
  end
  if exp.to_s.include? 'none' # internode encryption
    tmp_arr << 'none'
    tmp_arr << ' '
  else
    tmp_arr << 'all'
    if exp.to_s.include? 'false'
      tmp_arr << exp.to_s.scan(/all.*false/)[0].scan(/tls.*sha/)[0]      
    else
      tmp_arr << exp.to_s.scan(/all.*true/)[0].scan(/tls.*sha/)[0]
    end  
  end
  if exp.to_s.include? 'false' # client/server encryption
    tmp_arr << 'false'
    tmp_arr << ' '
  else
    tmp_arr << 'true'
    tmp_arr << exp.to_s.scan(/true.*/)[0].scan(/tls.*sha/)[0]
  end
  
  # parsing file content
  b = []
  b << "RunTime(ms)"
  b << "Throughput(ops/sec)"
  b << "Operations"
  b << "AverageLatency(us)"
  b << "MinLatency(us)"
  b << "MaxLatency(us)"
  b << "95thPercentileLatency(ms)"
  b << "99thPercentileLatency(ms)"
  File.open("#{cur_dir}/#{exp.to_s}").each_line do |line|
    #if line.to_s.start_with? '[OVERALL]' # get runtime and throughput
    #  tmp_arr << line.split(",")[2].strip!
    #end
    b.each do |item|
      if line.to_s.include? item
        if (line.to_s.include? "INSERT") && (! tmp_arr.include? "INSERT")
          tmp_arr << "INSERT"
        elsif (line.to_s.include? "READ") && (! tmp_arr.include? "READ")
          tmp_arr << "READ"
        elsif (line.to_s.include? "UPDATE") && (! tmp_arr.include? "UPDATE")
          tmp_arr << "UPDATE"
        end
        tmp_arr << line.split(",")[2].strip!        
      end
    end
  end
  
  # writing in CSV file
  CSV.open("results.csv", "a") do |csv|
    csv << tmp_arr
  end
end
