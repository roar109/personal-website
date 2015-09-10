# Weld - Java CDI

## CDI: Contexts & Dependency Injection for Java
- Overview
- Configuration
- Contexts and Usage
- Qualifiers
- Producers
- Threads
- Conclusions

### Overview
What is CDI? is the Java standard for dependency injection and contextual life cycle management and one of the most important and popular parts of the Java EE platform (JSR-346, JSR-299). Weld is the reference implementation of Java CDI and is used in the following topics.

I have been working with CDI for some months as a replace for Spring to make it more portable and dependency-free. My first thought is that is like EJB and this argument is not totally true nor false, although a combination of files and annotations to work as a complete set of components with a life cycle and a simple way of injection; problems came with complex examples fortunately my requirements were simple and I tackle easily.

My comments in the next sections were used in a JBoss EAP Web environment with JAX-RS and JAX-WS using Maven as dependency manager.

### Configuration

To use in a Web environment just add a `beans.xml` file in your `WEB-INF` folder, even if its empty it will work. You can also put the file in the `META-INF/beans.xml` when you use a jar or ear.

Use this maven dependency:

	<dependency>
		<groupId>javax.enterprise</groupId>
		<artifactId>cdi-api</artifactId>
		<version>1.2</version>
		<scope>provided</scope>
	</dependency>`

With this 2 options you are ready to go (I assume you already import the java EE dependencies needed)

### Contexts

What kind of classes are beans? JavaBeans and EJB session beans according to the specification. We can use EJB's and are handled in the same way as the normal EJB process.

The supported EJB's scopes are SessionScoped, Stateless, ConversationScoped, ApplicationScoped also EL with the @Named annotation are welcome and are processed in the same way EJB works.

**Usage**

We have a normal class:

	public class Foo{}

This simple class is a candidate for been a CDI bean, if you want to see it just inject it with the annotation `@Inject`:

	public class Bar{
		@Inject Foo fooInstance;
	...

The `@Inject` annotation can be used at attribute level, method or constructor.

This injection of an object instance is made at object-construct time this means when the caller-class ins constructed in addition you can use one option to get the instance in a different life cycle doing the following declare a Instance<T> as next:

`@Inject Instance<Foo> fooSource;`

Then in your method just call the `get()`. Each call to get will get you a different proxy object.

`Foo p = fooSource.get();`

## Qualifiers

By default when you use the @Inject annotation will search for a definition of the bean and create a proxy-instance, so what happen if we have more than one implementation of a class by default CDI will use the @Any or @Default annotations to label the bean classes. @Any is by default in all the CDI beans and overwrite the @Default. There is a way of define our Qualifiers to use in a  fashion way:

Suppose we have this 2 beans:

	public interface PaymentProcessor{}
	public class SynchronousPaymentProcessor implements PaymentProcessor
	public class AsynchronousPaymentProcessor implements PaymentProcessor

If you want to inject specific instance for example of `SynchronousPaymentProcessor` the you will need to create annotations like this:

	@Qualifier
	@Retention(RUNTIME)
	@Target({TYPE, METHOD, FIELD, PARAMETER})
	public @interface Synchronous {}
	
	@Qualifier
	@Retention(RUNTIME)
	@Target({TYPE, METHOD, FIELD, PARAMETER})
	public @interface Asynchronous {}

And injecting the new labeled instances in order to be able to pick up the correct one:

	@Synchronous
	public class SynchronousPaymentProcessor implements PaymentProcessor

	@Asynchronous
	public class AsynchronousPaymentProcessor implements PaymentProcessor

Injection will look like:

	@Inject @Synchronous PaymentProcessor syncPaymentProcessor;
	@Inject @Asynchronous PaymentProcessor asyncPaymentProcessor;
	
You can also declare the beans in the `beans.xml` to fix ambiguous dependencies, for example excluding duplicated classes or using a combination of annotations and xml declarations.

## Producers

You can create Producers methods that will create instances of a bean likewise this is using the `@Produces` annotation in a method, a common case where we can use this is a Logger of course is something you want to use in every bean class, for example (Taken from the documentation):

	import javax.enterprise.inject.spi.InjectionPoint;
	import javax.enterprise.inject.Produces;
	
	class LogFactory {
	   @Produces Logger createLogger(InjectionPoint injectionPoint) {
	      return Logger.getLogger(injectionPoint.getMember().getDeclaringClass().getName());
	   }
	}
	
And use it in your beans:

`@Inject Logger log;`

Note the `InjectionPoint` parameter refers to a meta data object of the injected object itself is useful for things like this where we need to know the caller class.

## Threads

By default the specification says: "The injection can't go across new threads" so, is single threaded. This is something I don't like about the CDI but my case I found a quick workaround passing the objects as reference in the new threads with the `instanceOfAclass.get()`.

The specification says that in case you want to connect to an existing contexts you can do it if you are using Conversation or Session scopes. This is defined in the FAQ first option.

## Conclusions

As I described at the beginning of the post I used CDI with JAX-RS and JAX-WS without any problems for simple solutions, for complex options I would recommend to build components or extensions, for example one coworker build a simple component to inject properties notably he uses the same CDI annotations with the Qualifier-extra-annotations and works seamlessly (even if you have your beans.xml at the WEB-INF you need to add it to the jar to be pickup by the weld container). This forces you to create or look for your own tools instead of have a big all-in-one solution like Spring. In conclusion I like it, but for big applications maybe can cause more maintenance work that it supposed to accomplish.

I missed a lot of Weld configurations and functionality. For further information you can check the official JBoss documentation. This was based in my personal experience.

[Weld Home Page](http://weld.cdi-spec.org/)
