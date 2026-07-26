# Earthbank Coffee Shop Simulator 8000
# Copyright 2022 (c) clydebank media, All RIghts Reserved.


#Import items from the random module to generate weather
import random

# Load customer data from Customer Directory.py
_customer_namespace = {}
with open("Customer Directory.py", "r") as _f:
    exec(_f.read(), _customer_namespace)
customer_data = [_customer_namespace[f"Customer{i}"] for i in range(1, 15)]

def welcome():
    print("Earthbank Coffee Shop Simulator 8000, Version 1.01")
    print("Copyright 2022 Clydebank Media,All Rights Reserved.\n.")
    print("Lets collect some information before we start the game.\n")

def prompt(display="please input a string", require=True):
    if require:
        s = False
        while not s:
            s = input(display + "")
        return s
    else:
        s = input(display + "")
        return s
  
def convert_to_float(s):
    try:
        f = float(s)
    except ValueError:
        f = 0
    return f 

def x_of_y(x, y):
    num_list = []
    for i in range(x):
        num_list.append(y)
    return num_list

class CoffeeShopSimulator:
    # Minimum and Maximum Temperature for the day
    temp_min = 10
    temp_max = 30
    
    def select_todays_customers(self, temperature, advertising):
        """Select which customers visit today based on temperature and advertising spend.
        Higher temperature and more advertising attract more customers."""
        num_customers = min(int((temperature - self.temp_min) * 0.8 + (advertising / 5)), len(customer_data))
        num_customers = max(1, num_customers)
        return random.sample(customer_data, num_customers)
    
    def __init__(self, player_name, shop_name):
        # Set Player and Shop names
        self.player_name = player_name
        self.shop_name = shop_name
        
        # Current day of the week, starting at 1 (Monday)
        self.day = 1 
        
        # Cash on hand for the shop, starting at $1000
        self.cash_on_hand = 1000.0
        
        # Inventory of coffee beans, starting at 100 units
        self.coffee_beans = 100
        
        # Sales List to keep track of daily sales
        self.sales_list = []
        
        # Customer visit log to track which customers came in on what day and temperature
        self.customer_visit_log = []
        
        # Track total money spent on inventory (purchasing coffee beans)
        self.total_inventory_spent = 0.0
        
        # Track total money spent on advertising
        self.total_advertising_spent = 0.0
        
        # Running totals across all days
        self.total_cups_sold_all = 0
        self.total_gross_profit_all = 0.0
        self.total_net_profit_all = 0.0
        
        # Possible Temperatures for the day, randomly generated between temp_min and temp_max
        self.temperature = random.randint(self.temp_min, self.temp_max)

    def run(self):
        # Main game loop
        while True:
            print(f"\n{'='*50}")
            print(f"DAY {self.day}")
            print(f"{'='*50}")
            print(f"Current Temperature: {self.temperature}°C")
            print(f"Cash on Hand: ${self.cash_on_hand:.2f}")
            print(f"Coffee Beans in Inventory: {self.coffee_beans} units")
            
            # --- PRE-DAY PURCHASES ---
            # Advertising purchase
            print("\n--- Pre-Day Purchases ---")
            print("You can buy advertisement for your shop to attract more customers.")
            advertising = prompt("How much would you like to spend on advertising today? (Enter a number) 0 for none: ", False)
            advertising = convert_to_float(advertising)
            while advertising > self.cash_on_hand:
                print(f"Not enough cash! You only have ${self.cash_on_hand:.2f}.")
                advertising = prompt("Enter a smaller amount for advertising: ", False)
                advertising = convert_to_float(advertising)
            self.cash_on_hand -= advertising
            self.total_advertising_spent += advertising
            print(f"  Advertising purchased: ${advertising:.2f}")
            
            # Inventory purchase
            print(f"\nYou currently have {self.coffee_beans} units of coffee beans.")
            inventory_purchase = prompt("How much would you like to spend on buying more coffee beans? ($1 = 10 units) 0 for none: ", False)
            inventory_purchase = convert_to_float(inventory_purchase)
            while inventory_purchase > self.cash_on_hand:
                print(f"Not enough cash! You only have ${self.cash_on_hand:.2f}.")
                inventory_purchase = prompt("Enter a smaller amount for inventory: ", False)
                inventory_purchase = convert_to_float(inventory_purchase)
            self.cash_on_hand -= inventory_purchase
            self.total_inventory_spent += inventory_purchase
            beans_purchased = int(inventory_purchase * 10)
            self.coffee_beans += beans_purchased
            if beans_purchased > 0:
                print(f"  Purchased {beans_purchased} units of coffee beans.")
            
            # Cup price
            cup_price = prompt("\nWhat price would you like to set for a cup of coffee today? (Enter a number): ", True)
            cup_price = convert_to_float(cup_price)
            
            cost_per_cup = 0.5  # Cost the player pays for each cup of coffee sold

            # --- RUN THE DAY (one customer at a time) ---
            print(f"\n--- Running Day {self.day} Sales ---")
            
            # Select which customers visit today
            todays_customers = self.select_todays_customers(self.temperature, advertising)
            # Shuffle them so they arrive in random order
            random.shuffle(todays_customers)
            
            cups_sold_today = 0
            gross_profit_today = 0.0
            customer_purchases = []
            day_ended_early = False
            
            for customer in todays_customers:
                # Check if we still have inventory
                if self.coffee_beans <= 0:
                    day_ended_early = True
                    break
                
                # Each customer's likelihood to buy is influenced by temperature and advertising
                buy_chance = (self.temperature - self.temp_min) / (self.temp_max - self.temp_min) * 0.6 + 0.2
                buy_chance += advertising / 200
                buy_chance = min(1.0, max(0.1, buy_chance))
                
                bought_something = False
                if random.random() < buy_chance:
                    # Customer buys 1-3 cups
                    cups_bought = 1
                    if cup_price <= 2.0:
                        cups_bought += 1
                    if self.temperature >= 20:
                        cups_bought += 1
                    cups_bought = min(cups_bought, 3)
                    
                    # Can we fulfill this order?
                    actual_cups = min(cups_bought, self.coffee_beans)
                    if actual_cups > 0:
                        self.coffee_beans -= actual_cups
                        cups_sold_today += actual_cups
                        spent = round(actual_cups * cup_price, 2)
                        gross_profit_today += spent
                        customer_purchases.append({
                            "customer": customer["name"],
                            "cups": actual_cups,
                            "spent": spent
                        })
                        bought_something = True
                        
                        # Log this customer visit
                        self.customer_visit_log.append({
                            "day": self.day,
                            "temperature": self.temperature,
                            "customer_name": customer["name"],
                            "cups_purchased": actual_cups,
                            "amount_spent": spent,
                            "advertising_spent": advertising
                        })
                
                # Show progress
                status = f"  {customer['name']}"
                if bought_something:
                    p = customer_purchases[-1]
                    status += f" bought {p['cups']} cup(s) for ${p['spent']}"
                else:
                    status += " visited but didn't buy"
                print(status)
                
                # Check if inventory just ran out
                if self.coffee_beans <= 0:
                    day_ended_early = True
                    print("  *** INVENTORY RAN OUT! ***")
                    break

            # --- END OF DAY CALCULATIONS ---
            net_profit_today = gross_profit_today - (cups_sold_today * cost_per_cup)
            self.cash_on_hand += net_profit_today
            self.total_cups_sold_all += cups_sold_today
            self.total_gross_profit_all += gross_profit_today
            self.total_net_profit_all += net_profit_today
            
            # Save to sales list
            self.sales_list.append({
                "day": self.day,
                "temperature": self.temperature,
                "cup_price": cup_price,
                "advertising": advertising,
                "cups_sold": cups_sold_today,
                "gross_profit": gross_profit_today,
                "net_profit": net_profit_today
            })
            
            # --- DISPLAY RESULTS ---
            if day_ended_early:
                # GAME OVER - inventory ran out
                print(f"\n{'='*50}")
                print(f"  GAME OVER - {self.shop_name} ran out of coffee beans!")
                print(f"{'='*50}")
                print(f"\n--- FINAL STATS ---")
                print(f"Days survived: {self.day}")
                print(f"Total cups sold: {self.total_cups_sold_all}")
                print(f"Total gross profit: ${self.total_gross_profit_all:.2f}")
                print(f"Total net profit: ${self.total_net_profit_all:.2f}")
                print(f"Total advertising spent: ${self.total_advertising_spent:.2f}")
                print(f"Total inventory spent: ${self.total_inventory_spent:.2f}")
                print(f"Final cash on hand: ${self.cash_on_hand:.2f}")
                print(f"Remaining inventory: {self.coffee_beans} units")
                print(f"\nTotal customer visits logged: {len(self.customer_visit_log)}")
                print(f"\nThanks for playing, {self.player_name}!")
                break
            else:
                # Day completed successfully
                print(f"\n--- DAY {self.day} COMPLETE ---")
                print(f"Cups sold today: {cups_sold_today}")
                print(f"Gross profit today: ${gross_profit_today:.2f}")
                print(f"Net profit today: ${net_profit_today:.2f}")
                print(f"Remaining coffee beans: {self.coffee_beans} units (carried to next day)")
                print(f"Cash on hand: ${self.cash_on_hand:.2f}")
                
                # Ask if player wants to continue
                continue_choice = prompt("\nStart next day? (yes/no): ", True).strip().lower()
                if continue_choice != "yes" and continue_choice != "y":
                    # Player quit voluntarily - show stats
                    print(f"\n{'='*50}")
                    print(f"  {self.shop_name} - Session Complete!")
                    print(f"{'='*50}")
                    print(f"\n--- FINAL STATS ---")
                    print(f"Days played: {self.day}")
                    print(f"Total cups sold: {self.total_cups_sold_all}")
                    print(f"Total gross profit: ${self.total_gross_profit_all:.2f}")
                    print(f"Total net profit: ${self.total_net_profit_all:.2f}")
                    print(f"Total advertising spent: ${self.total_advertising_spent:.2f}")
                    print(f"Total inventory spent: ${self.total_inventory_spent:.2f}")
                    print(f"Final cash on hand: ${self.cash_on_hand:.2f}")
                    print(f"Remaining inventory: {self.coffee_beans} units")
                    print(f"Total customer visits logged: {len(self.customer_visit_log)}")
                    print(f"\nThanks for playing, {self.player_name}!")
                    break
                
                # Increment day and generate new temperature
                self.day += 1
                self.temperature = random.randint(self.temp_min, self.temp_max)

    def make_temp_distribution(self): 
        # Create a distribution of temperatures weighted toward the average
        temp_distribution = []
        # Find average between TEMP_MIN and TEMP_MAX
        avg = (self.temp_min + self.temp_max) / 2
        #Find the maximum distance from average
        max_dis_from_avg = self.temp_max - avg

        for i in range(self.temp_min, self.temp_max + 1):
            dis_from_avg = abs(i - avg)
            # Calculate a weight inversely proportional to distance from average
            if max_dis_from_avg == 0:
                probability = 1
            else:
                probability = 1 - (dis_from_avg / max_dis_from_avg)
            probability = max(0, probability)

            # Add this temperature to the distribution list based on its probability
            count_primary = int(probability * 100)
            temp_distribution.extend(x_of_y(count_primary, i))

            # Add a smaller secondary weight based on distance from max distance
            dist_from_max_dist = max_dis_from_avg - dis_from_avg
            if dist_from_max_dist <= 0:
                dist_from_max_dist = 1
            count_secondary = int(dist_from_max_dist * 10)
            temp_distribution.extend(x_of_y(count_secondary, i))

        return temp_distribution

    def increment_day(self):
        # Increment the day and generate a new temperature
        self.day += 1
        temp_distribution = self.make_temp_distribution()
        self.temperature = random.choice(temp_distribution)
        
    def daily_stats(self, temperature, cup_price, advertising, cups_sold, gross_profit, net_profit):
        # Display the results
        print("You sold " + str(int(cups_sold)) + " cups of coffee today.")
        print("Your gross profit for the day is: $" + str(round(gross_profit, 2)))
        print("Your net profit for the day is: $" + str(round(net_profit, 2)))

    def day_header(self):
        print(f"\nDay {self.day}:")
        print(f"Current Temperature: {self.temperature}°C")
        print(f"Cash on Hand: ${self.cash_on_hand:.2f}")
        print(f"Coffee Beans in Inventory: {self.coffee_beans} units")
        
    def daily__sales(self, temperature, cup_price, advertising):
        customers = self.select_todays_customers(temperature, advertising)
        return self.simulate(temperature, cup_price, advertising, customers)

    @property 
    def weather(self):
        return random.choice(self.make_temp_distribution())

# Print Welcome message
welcome()

# Get Name and Store Name
player_name = prompt("What is your name? ", True)
shop_name = prompt("What is the name of your coffee shop? ", True)

# Create The Game Object
game = CoffeeShopSimulator(player_name, shop_name)

# Personalized welcome before starting sales
print(f"\n=== Welcome, {player_name}, to {shop_name}! ===")
print(f"Let's start serving our customers and tracking sales.\n")

# Run it
game.run()
