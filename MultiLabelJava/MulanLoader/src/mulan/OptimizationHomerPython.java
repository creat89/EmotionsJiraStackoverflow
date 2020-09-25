package mulan;

import py4j.GatewayServer;

public class OptimizationHomerPython
{
	
	public MulanLoader getMulanLoader()
	{
		System.out.println("--------------------------------------New experiment---------------------------------------------");
		return new MulanLoader();
	}
	
	public static void main(String[] args)
	{
		 GatewayServer gatewayServer = new GatewayServer(new OptimizationHomerPython(),25335);
		 gatewayServer.start();
	     System.out.println("Gateway Server Started");
	}
}
