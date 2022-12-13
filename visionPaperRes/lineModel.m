clear
model = LayeredNetwork('simpleLQN');

w=100;

Pc = Processor(model, 'Pc', w, SchedStrategy.INF);
Pr = Processor(model, 'Pr', w, SchedStrategy.PS);
Pf = Processor(model, 'Pf', w, SchedStrategy.PS);


Client = Task(model, 'Client', w, SchedStrategy.REF).on(Pc);
Router = Task(model, 'Router', w/10, SchedStrategy.PS).on(Pr);
Front_end = Task(model, 'Front_end', w, SchedStrategy.PS).on(Pf);

browse = Entry(model, 'browse').on(Client);
address = Entry(model, 'address').on(Router);
home = Entry(model, 'home').on(Front_end);
catalog = Entry(model, 'catalog').on(Front_end);
cart = Entry(model, 'cart').on(Front_end);

A1 = Activity(model, 'A1', Exp(1.0)).on(Client).boundTo(browse).synchCall(address,1.0);
%A2 = Activity(model, 'A2', Exp(0.01)).on(Router).boundTo(address).synchCall(home,1.0);

A23 = Activity(model, 'A23', Exp(1/0.01)).on(Router).boundTo(address).asynchCall(home,1.0);
A24 = Activity(model, 'A24', Exp(1e05)).on(Router).asynchCall(catalog,1.0);
A25  = Activity(model, 'A25',Exp(1e05)).on(Router).repliesTo(address).asynchCall(cart,1.0);
Router.addPrecedence(ActivityPrecedence.Serial(A23, A24, A25));

A3 = Activity(model, 'A3', Exp(1/0.03)).on(Front_end).boundTo(home).repliesTo(home);
A4 = Activity(model, 'A4', Exp(1/0.06)).on(Front_end).boundTo(catalog).repliesTo(catalog);
A5 = Activity(model, 'A5', Exp(1/0.08)).on(Front_end).boundTo(cart).repliesTo(cart);

%SolverMVA(model,'exact').getAvgTable()
options = SolverLN.defaultOptions;
mvaopt = SolverMVA.defaultOptions;
res=SolverLN(model, @(layer) SolverMVA(layer, mvaopt), options).getAvgTable;

rt=res.RespT(7)-1;