package pacConfluenceTest;
import java.util.concurrent.TimeUnit;
import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.testng.Assert;
import org.testng.annotations.Test;
import com.gargoylesoftware.htmlunit.javascript.host.URL;

public class ConfluenceAutoTest {
	public static void main(String[] args) {

		// System.out.println("Hello");
		ConfluenceAutoTest conft = new ConfluenceAutoTest();
		/*conft.tcaseforLogin();
		conft.tcaseLoginWithUserIdAndPassword();
		conft.tcaseloginWithSAML();
		conft.tcaseforLogout();
		conft.tcaseforConfluenceviewspaces();
		conft.tcaseforseacrhconfluencespace();
		conft.tcaseforintegrationwithJira();*/
		//conft.tcaseforViewAddons();
	}

	@Test(alwaysRun = true)
	public void tcaseforLogin()

	{
		System.setProperty("webdriver.chrome.driver", auth.chromedriverpath);
		// Initiate.chromedriverpath);

		WebDriver driver = new ChromeDriver();
		try {
			driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);
			// Navigate to URL
			driver.get(auth.strURL);
			driver.getTitle();
			// Maximize the window
			driver.manage().window().maximize();

		} catch (Exception e) {
			System.out.println(e);
			org.testng.Assert.fail("Test case failed for Login");
			driver.quit();

		} finally {

			System.out.println("tcaseforLogin");
			driver.quit();
		}

	}

	@Test(alwaysRun = true)
	public void tcaseLoginWithUserIdAndPassword() {

		System.setProperty("webdriver.chrome.driver", auth.chromedriverpath);
		// Initiate.chromedriverpath)
		WebDriver driver = new ChromeDriver();
		try {

			
			// Navigate to URL
			driver.get(auth.strURL);
			// Maximize the window.
			// click in user id password link
			driver.findElement(By.linkText("Login with username and password")).click();
			// Enter UserName
			driver.findElement(By.id("os_username")).sendKeys(auth.username);
			// Enter Password
			driver.findElement(By.id("os_password")).sendKeys(auth.password);
			// enter the login button
			driver.findElement(By.id("loginButton")).click();

		} catch (Exception e) {
			System.out.println(e);
			org.testng.Assert.fail("Test case failed for Login with user ID & Password");
			driver.quit();

		} finally {

			System.out.println("tcaseLoginWithUserIdAndPassword");
			driver.quit();
		}

	}

	@Test(alwaysRun = true)
	public void tcaseloginWithSAML() {
		System.setProperty("webdriver.chrome.driver", auth.chromedriverpath);
		;
		// Initiate.chromedriverpath);

		WebDriver driver = new ChromeDriver();
		
		// Navigate to URL
		
		try {
			//driver.get("https://confluence.csc.com/");
			driver.get(auth.strURL);
			// Maximize the window.
			driver.manage().window().maximize();
			// click in SAML Link
			driver.findElement(By.linkText("DXCGLOBALPASS")).click();
			// Enter UserName
			driver.findElement(By.name("USER")).sendKeys(auth.SAMLusername);
			// Enter Password
			driver.manage().timeouts().implicitlyWait(60, TimeUnit.SECONDS);
			driver.findElement(By.name("PASSWORD")).sendKeys(auth.SAMLpassword);
			// Wait For Page To Load
			driver.manage().timeouts().implicitlyWait(60, TimeUnit.SECONDS);
			// Click on 'Sign In' button
			driver.findElement(By.id("loginbtn")).click();
		} catch (Exception e) {
			System.out.println(e);
			org.testng.Assert.fail("Test case failed for Login with SAML");
			driver.quit();

		} finally {

			System.out.println("tcaseloginWithSAML");
			driver.quit();
		}
	}

	@Test(alwaysRun = true)
	public void tcaseforLogout() {
		System.setProperty("webdriver.chrome.driver", auth.chromedriverpath);
		// Initiate.chromedriverpath);

		WebDriver driver = new ChromeDriver();
		try {
			driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);
			// Navigate to URL
			driver.get(auth.strURL);
			// Maximize the window.
			driver.manage().window().maximize();
			// click in SAML Link
			driver.findElement(By.linkText("Login with username and password")).click();
			// Enter UserName
			driver.findElement(By.id("os_username")).sendKeys(auth.username);
			// Enter Password
			driver.findElement(By.id("os_password")).sendKeys(auth.password);
			// enter the login button
			driver.findElement(By.id("loginButton")).click();
			driver.manage().timeouts().implicitlyWait(20, TimeUnit.SECONDS);
			// driver.findElement(By.id("content-hover-20")).click();
			driver.findElement(By.id("user-menu-link")).click();
			driver.findElement(By.id("logout-link")).click();
		
		} catch (Exception e) {
			System.out.println(e);
			org.testng.Assert.fail("Test case failed for Logout");
			driver.quit();

		} finally {

			System.out.println("tcaseforLogout");
			driver.quit();
		}

	}

	@Test(alwaysRun = true)
	public void tcaseforConfluenceviewspaces() {

		System.setProperty("webdriver.chrome.driver", auth.chromedriverpath);

		WebDriver driver = new ChromeDriver();
		try {
			driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);
			// Navigate to URL
			driver.get(auth.strURL);
			// Maximize the window.
			driver.manage().window().maximize();
			// click in SAML Link
			driver.findElement(By.linkText("Login with username and password")).click();
			// Enter UserName
			driver.findElement(By.id("os_username")).sendKeys(auth.username);
			// Enter Password
			driver.findElement(By.id("os_password")).sendKeys(auth.password);
			// enter the login button
			driver.findElement(By.id("loginButton")).click();
			// Wait For Page To Load

			driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
			driver.findElement(By.id("space-menu-link")).click();
			driver.findElement(By.id("view-all-spaces-link")).click();
			driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);

		} catch (Exception e) {
			System.out.println(e);
			org.testng.Assert.fail("Test case failed for view confluence spaces ");
			driver.quit();

		} finally {

			System.out.println("tcaseforConfluenceviewspaces");
			driver.quit();
		}

	}

	@Test(alwaysRun = true)
	public void tcaseforseacrhconfluencespace() {

		System.setProperty("webdriver.chrome.driver", auth.chromedriverpath);

		WebDriver driver = new ChromeDriver();
		try {
			driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);
			// Navigate to URL
			driver.get(auth.strURL);
			// Maximize the window.
			driver.manage().window().maximize();
			// click in SAML Link
			driver.findElement(By.linkText("Login with username and password")).click();
			// Enter UserName
			driver.findElement(By.id("os_username")).sendKeys(auth.username);
			// Enter Password
			driver.findElement(By.id("os_password")).sendKeys(auth.password);
			// enter the login button
			driver.findElement(By.id("loginButton")).click();
			// Wait For Page To Load

			driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
			driver.findElement(By.id("space-menu-link")).click();
			driver.findElement(By.id("view-all-spaces-link")).click();
			driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
			driver.findElement(By.id("space-search-query")).sendKeys("client demo");
			driver.findElement(By.id("space-search-query")).sendKeys(Keys.ENTER);
		} catch (Exception e) {
			System.out.println(e);
			org.testng.Assert.fail("Test case failed for confluenc space search");
			driver.quit();

		} finally {

			System.out.println("tcaseforseacrhconfluencespace");
			driver.quit();
		}

	}

	@Test(alwaysRun = true)
	public void tcaseforintegrationwithJira() {

		System.setProperty("webdriver.chrome.driver", auth.chromedriverpath);

		WebDriver driver = new ChromeDriver();
		try {
			driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);
			// Navigate to URL
			driver.get(auth.strURL);
			// Maximize the window.
			driver.manage().window().maximize();
			// click in SAML Link
			driver.findElement(By.linkText("Login with username and password")).click();
			// Enter UserName
			driver.findElement(By.id("os_username")).sendKeys(auth.username);
			// Enter Password
			driver.findElement(By.id("os_password")).sendKeys(auth.password);
			// enter the login button
			driver.findElement(By.id("loginButton")).click();
			// Wait For Page To Load

			driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
			driver.findElement(By.id("space-menu-link")).click();
			driver.findElement(By.id("view-all-spaces-link")).click();
			driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
			driver.findElement(By.id("space-search-query")).sendKeys("client demo");
			driver.findElement(By.id("space-search-query")).sendKeys(Keys.ENTER);
			driver.findElement(By.linkText("Client Demo")).click();
			driver.findElement(By.linkText("CDP Requirements Tractability Matrix - Release CDP-3.2")).click();
			//driver.findElement(By.id("editPageLink")).click();
			//driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
			//driver.findElement(By.id("rte-button-insert")).click();
			//driver.findElement(By.id("jiralink")).click();
			//driver.findElement(By.name("jiraSearch")).sendKeys("CDP-654");
			//driver.findElement(By.name("jiraSearch")).sendKeys(Keys.ENTER);
			// driver.findElement(By.xpath("//button[@class='button-panel-button
			// insert-issue-button']")).click();
			// driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);

			// driver.findElement(By.linkText("CDP Requirements Tractability Matrix -
			// Release CDP-3.2")).click();

			// driver.findElement(By.id("rte-button-publish")).click();
		} catch (Exception e) {
			System.out.println(e);
			org.testng.Assert.fail("Test case failed for confluence integration with Jira");
			driver.quit();

		} finally {

			System.out.println("tcaseforConfluenceIntegration");
			driver.quit();
		}

	}

	@Test(alwaysRun = true)
	public void tcaseforViewAddons() {

		System.setProperty("webdriver.chrome.driver", auth.chromedriverpath);

		WebDriver driver = new ChromeDriver();
		try {
			driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);
			// Navigate to URL
			driver.get(auth.strURL);
			// Maximize the window.
			driver.manage().window().maximize();
			// click in SAML Link
			driver.findElement(By.linkText("Login with username and password")).click();
			// Enter UserName
			driver.findElement(By.id("os_username")).sendKeys(auth.username);
			// Enter Password
			driver.findElement(By.id("os_password")).sendKeys(auth.password);
			// enter the login button
			driver.findElement(By.id("loginButton")).click();
			// Wait For Page To Load
			driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
			driver.findElement(By.id("admin-menu-link")).click();
			driver.findElement(By.id("plugin-administration-link")).click();
			driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);
			
			
			driver.findElement(By.id("password")).sendKeys(auth.password);
			driver.findElement(By.id("authenticateButton")).click();
			
			driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);

		} 
		catch (NoSuchElementException  e1)
		{
			driver.quit();
		}
		catch (Exception e) {
			System.out.println(e);
			org.testng.Assert.fail("Test case failed for view Add-Ons ");
		driver.quit();

		} finally {

			System.out.println("tcaseforConfluenceviewAdd-ons");
		driver.quit();
		}

	}	
	
}
