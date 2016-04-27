# Sefirah

### Status
##### wip  
<br>
### Installation Notes


The following code must be changed within the KosherCocoa framework in order for English text to appear:
> https://github.com/MosheBerman/KosherCocoa/blob/master/KosherCocoa/Library/Core/Calendar/Sefira/KCSefiraFormatter.m#L610  

Change:
```
@[
   @[_englishStrings]
 ],
 ```
To:
```
@[
   _englishStrings
 ],
 ```

 This will prevent issues with array indices when the framework accesses the array of english strings for the omer.