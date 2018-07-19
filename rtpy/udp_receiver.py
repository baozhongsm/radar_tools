import socket

myname = socket.getfqdn(socket.gethostname())               #获取本地ip
lo = socket.gethostbyname(myname)

address = (lo, 10001)                                      #这里注意不能使用127.0.0.1
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)  
s.bind(address)
  
print("等待数据")
data, addr = s.recvfrom(2048)
print("判决")  

print("received:", data, "from", addr)  
print(data.hex())
s.close()