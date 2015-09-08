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
I have been working with CDI for some months as a replace for Spring, just to make it more portable and dependency-free. My first thought is that is like EJB and this argument is not totally true nor false, is combination of files + annotations to do a complete set of components with a life cycle and a way of injection quite simple, the problems came with more complex examples fortunately my requirements were simple.

My comments in the next sections were used in a JBoss EAP in a Web environment with JAX-RS and JAX-WS using Maven as dependency manager.

### Configuration

To use in a Web environment just add a `beans.xml` file in your `WEB-INF` folder, even if is empty it will work. You can also put the file in the `META-INF/beans.xml` when you use a jar or ear.

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

So we have the EJB's scopes like SessionScoped, Stateless, ConversationScoped, ApplicationScoped also EL with the @Named annotation finally we have some alternatives that we can use, we will describe that in the Qualifiers section.

**Usage**

`public class PaymentProcessor{}`

This simple class is a candidate for been a CDI bean, if you want to see it just inject it with the annotation `@Inject`

`@Inject PaymentProceesor processor;`

The `@Inject` annotation can be used at attribute level, method or constructor.

This injections are made at instantiation time, but if you want you can use one option to get the instance in a different lifecycle, doing the following:

`@Inject Instance<PaymentProcessor> paymentProcessorSource;`

then in your methods: 

`PaymentProcessor p = paymentProcessorSource.get();`

## Qualifiers

By default when you use the @Inject annotation will search for a definition of the bean and create an instance, so what happen if we have more than one implementation of a class, by default CDI will use the @Any or @Default instance. @Any is by default in all the CDI beans and overwrite the @Default.

Suppose we have this 2 beans:

	public class SynchronousPaymentProcessor implements PaymentProcessor
	public class AsynchronousPaymentProcessor implements PaymentProcessor

If you want to inject specific instance you can create annotations like this ones:

	@Qualifier
	@Retention(RUNTIME)
	@Target({TYPE, METHOD, FIELD, PARAMETER})
	public @interface Synchronous {}
	
	@Qualifier
	@Retention(RUNTIME)
	@Target({TYPE, METHOD, FIELD, PARAMETER})
	public @interface Asynchronous {}

Injecting the new labeled instances:

	@Inject @Synchronous PaymentProcessor syncPaymentProcessor;
	@Inject @Asynchronous PaymentProcessor asyncPaymentProcessor;
	
## Producers

You can create Producers methods that will create instances of a bean, this is using the `@Produces` annotation in a method, a common case where we can use this is a Logger, is something you want to use in every major class, for example:

	import javax.enterprise.inject.spi.InjectionPoint;
	import javax.enterprise.inject.Produces;
	
	class LogFactory {
	   @Produces Logger createLogger(InjectionPoint injectionPoint) {
	      return Logger.getLogger(injectionPoint.getMember().getDeclaringClass().getName());
	   }
	}
	
And use it in your beans:

`@Inject Logger log;`

Note the InjectionPoint parameter refers to a meta data of the injected object, the one that call this `@Produces`.

## Threads

By default the specification said: "The injection can't go across new threads" so, is single threaded. This is something I don't like about the CDI, but well for my case I found a quick workaround passing the objects as reference in the new threads and not use a lot.

It specifies that in case you want to connect to an existing contexts you can do it,  if you are using Conversation or Session scopes. Its defined in the FAQ first option.

## Conclusions

As I describe at the beginning of the post I use CDI with JAX-RS and JAX-WS without any problem, for simple solutions is a very good option, for complex options I would recommend to build components or extensions, for example one coworker build a simple component to inject properties, it use the same CDI annotations with the Qualifier extra annotations, works seamless (even if you have your beans.xml at the WEB-INF you need to add it to the jar to be pickup by the weld container). This forces you to crete or look for other tools instead of a big all-in-one solution like spring. In conclusion I like it, but for big applications maybe can cause more work that it suppose to accomplish.

I miss a lot of Weld configurations and functionality, you can check it in the official documentation. This was based in my personal experience with it.

[Weld Home Page](http://weld.cdi-spec.org/)
