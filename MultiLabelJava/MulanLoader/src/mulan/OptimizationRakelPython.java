package mulan;

import py4j.GatewayServer;

public class OptimizationRakelPython
{
	
	public MulanLoader getMulanLoader()
	{
		System.out.println("--------------------------------------New experiment---------------------------------------------");
		return new MulanLoader();
	}
	
	public static void main(String[] args)
	{
		//The default value is 25333, we change it to have multiple servers running
		 GatewayServer gatewayServer = new GatewayServer(new OptimizationRakelPython(),25333);
		 gatewayServer.start();
	     System.out.println("Gateway Server Started");
	}
}
