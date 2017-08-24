# LocationWithoutPrompt

A proof of concept to show how easy it is to get coarse location of the user without using Core Location

## Steps

1. This uses SystemConfiguration framework to get the connected network point. 
2. From there, we get the Mac Address of your router and send it to these awesome guys @ https://www.mylnikov.org
3. The resulting location is shown on a MapView.

Simple huh?

## Licensing
The code is licensed under GPL. Yep, you guessed it. I pretty much don't want anyone to use this. This is a proof of concept code.

## Thoughts
I'm not sure if this is a serious security/privacy hole. Apple can only prevent developers from getting the Mac Address of the phone and not that of the connected router, though I'm not sure on this. I'll raise a rdar and update the README with the link.
