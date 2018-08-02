# How to configure the SAML Vendor plugin version 0.14.7
## Installing SAML vendor single-sign on plugin
* Download the samlsso-confluence-0.14.7.jar & samlSingleSignOn-confluence.xml into your local directory <br>
* The above 2 files are available in /SAML-Restore folder
* Login to confluence <br>
* Select the add-ons from confluence adminstartion menu <br>
* select the Uplpad App link and click on Choose file and select the samlsso-confluence-0.14.7.jar from your local directory <br>
* The screen shot is available in ![Image of How to add SAML add-on](Images/add-ons.png) <br>
* The installation will take 2 to 3 min and once done The **_"SAML SingleSignOn for Confluence"** will appear in the add-ons list
* Expand the plugin and check the installed plugin version is 0.14.7
* click on License Key and add the below license key and update (The licenes key automatically applied when you install the jar file and of if you not see the license key , copy the below licene key and apply<br>
/***<table><b>License Key</b><tr><th>AAABag0ODAoPeNqVkV9rwjAUxd/zKQJ70QdLWzc3hcKk9mFg7VjdnvZyjbc1kKblJpH57ZdWZX/eD
ISQe5Nfzjm52x4cz4F4HPMoXISPi3jO09WWx2H0xDau2SEV1btBMkkU+sFWaATJzspWJ+UyX/NS6
lqhX2rNC81HZVmMedUST1tdKYda4P/tqEQ6Io35gOQD/nPhTzQNkpCg+FoK1AZZSgj9UyuwmPSaJ
uF0Ek+Zh1kQdgMNJssG9B74pt0pvDayHKRKQPe1Z2FEINqGZUdQbsAlFShP98WA0LTK9cUArALTK
VdLbQIDjTKmDX5kB54rj5hYcsjUWeCHV97z4ltZpQWySBchXq22qMF3sq9O0unqd977jWasoBq0N
GfxPqfO+cu8FLKHGZ8cdS0NXVZmm8TPyWx+H8UPU3aJ8hfXaSUbaXF/7W1PHQ5RpkWeZ2/py3J9q
x/0+qkjaS75vDoSBzD45+O8kW+SRNp1MCwCFFONtC6vqVtoCtn+qGozdh1k0od/AhRfoS0Phs0BS
0MkwHuCQ7eBb+8j2Q==X02hp</th></tr></table> ***/<br>
* After installing the plugin and expand the plugin and select the configure ![Image of SAML](Images/SAML.png) <br>
## SAML Identity Provider Settings
* Goto to bottom of the page and select the Import XML button and select the **"samlSingleSignOn-confluence.xml"** from your local directory and click on ok and after importing the check whether the below values are appearing in the configuration <br>
* Please check  ![Image of SAML settings](Images/SAML-settings.png) <br>
<table><tr><th>Name</th><th>DXCGLOBALPASS</th></tr> 
<tr><th>Description</th><th>DXCGLOBALPASS</th></tr>
 
</table>

## SAML Template configuration
