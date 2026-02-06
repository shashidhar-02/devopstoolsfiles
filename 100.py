s=input()
res=" "
for ch in s:
    if ch not in res:
        res+=ch 
s=input()
res=" "
for ch in s:
    if ch not in res:
        res+=ch
print(ch)

print(res)
n=int(input())
def isprime(num):
    if num<2:
        return False
    for i in range(2,int(num**0.5)+1):
        if i*i>num:
            break
        if num %i==0:
            return False
    return True
n+=1
while not isprime(n):
    n+=1
print(n)
n=int(input())
def isprime(num):
    if num<2:
        return False
    for i in range(2,int(num**0.5)+1):
        if i*i>num:
            break
        if num%i==0:
            return False
    return True
n+=1
while not isprime(n):
    n+=1
print(n)

        
s=input()
freq={}
for ch in s:
    freq[ch]=freq.get(ch,0)+1
count=0
for ch in s:
    if freq[ch]==1:
        count+=1
    if count==2:
        print(ch)
        break
s=input()
freq={}
for ch in s:
    freq[ch]=freq.get(ch,0)+1
count=0
for ch in s:
    if freq[ch]==1:
        count+=1
    if count==2:
        print(ch)
        break
    
s=input()
vowels="aeiouAEIOU"
vc=0
cc=0
dc=0
sc=0
for ch in s:
    if ch.isalpha():
        if ch in vowels:
            vc+=1
        else:
            cc+=1
    elif ch.isdigit():
        dc+=1
    else:
        sc+=1
print(vc,cc,dc,sc)
s=input()
vowels="aeiouAEIOU"
vc=0
cc=0
dc=0
sc=0
for ch in s:
    if ch.isalpha():
        if ch in vowels:
            vc+=1
        else:
            cc+=1
    elif ch.isdigit():
        dc+=1
    else:
        sc+=1
print(vc,cc,dc,sc)

lst=list(map(int,input().split()))
even=0
odd=0
for num in lst:
    if num%2==0:
        even+=1
    else:
        odd+=1
print(even,odd)
lst=list(map(int,input().split()))
even=0
odd=0
for num in lst:
    if num%2==0:
        even+=1
    else:
        odd+=1
print(even,odd)

    
