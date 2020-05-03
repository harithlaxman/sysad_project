#NORMAL MODE
sudo adduser --force-badname MasterH
sudo adduser --force-badname Heisenberg
sudo adduser --force-badname Hertz
sudo adduser --force-badname Holland
sudo addgroup --force-badname IHeisenberg
sudo addgroup --force-badname IHertz
sudo addgroup --force-badname IHolland
sudo usermod -a -G Scientist Heisenberg
sudo usermod -a -G Scientist Hertz
sudo usermod -a -G Scientist Holland
declare -a scientist
declare -a iheisenberg ihertz iholland
scientist=(Heisenberg Hertz Holland)
for i in {1..3}
 do
  cd /home/${scientist[$i-1]}
  mkdir task{1..5}
  sudo chmod u+rwx o-rwx task{1..5}
  sudo setfacl -m u:MasterH:rwx task{1..5}
  for k in {1..5}
   do
    cd ../task$k
    touch ${scientist[$i-1]}_task{1..50}.txt
    for l in {1..50}
     do
      shuf -i 0-127 -n 128 | awk '{printf "%c", $1}' | xargs -0 >> task$l
     done
    done
  for j in {1..20}
   do
    sudo adduser --force-badname ${scientist[$i-1]}$j
    i${scientist[$i-1]}[j]=${scientist[$i-1]}$j
    sudo usermod -a -G I${scientist[$i-1]} ${scientist[$i-1]}$j
    cd /home/${scientist[$i-1]}$j
    mkdir task{1..5}
    sudo chmod g-rwx u+rwx o-rwx /home/${scientist[$i-1]}${j}/task{1..5}
    sudo setfacl -m u:${scientist[$i-1]}:rwx task{1..5}
    sudo setfacl -m u:MasterH:rwx task{1..5}
    for m in {1..5}
     do
      echo "0 0 * * * find /home/${scientist[$i-1]}/ -type f -name "*.txt" -print0 | xargs -0 shuf -e -n 5 -z | xargs -0 cp -vt /home/${scientist[$i-1]}${j}/task$m" >> /var/spool/cron/root
     done
     #adding success and failure files in intern users
    touch success.txt failure.txt
    wget https://delta.nitt.edu/~deeraj/server_logs.txt
    echo Time Hostname > success.txt
    echo Time Hostname > failure.txt
    grep -e "${scientist[$i-1]} -> ${scientist[$i-1]}-Intern${j}$" server_logs.txt | awk '{print $1 " " $2}' | xargs -0 >> success.txt
    grep -e "MasterH -> ${scientist[$i-1]}-Intern${j}$" server_logs.txt | awk '{print $1 " " $2}' | xargs -0 >> success.txt
    let ns="${grep -e "${scientist[$i-1]} -> ${scientist[$i-1]}-Intern${j}$" server_logs.txt | wc -l}" + "${grep -e "MasterH -> ${scientist[$i-1]}-Intern${j}$" server_logs.txt | wc -l}"
    echo "Total Number of success hits = $ns"
    grep -e " -> ${scientist[$i-1]}-Intern${j}$" server_logs.txt | grep -e "${scientist[$i-1]} " -v | awk '{print $1 " " $2}' | xargs -0 >> failure.txt
    grep -e " -> ${scientist[$i-1]}-Intern${j}$" server_logs.txt | grep -e "MasterH " -v | awk '{print $1 " " $2}' | xargs -0 >> failure.txt
    let nf="${grep -e " -> ${scientist[$i-1]}-Intern${j}$" server_logs.txt | grep -e "${scientist[$i-1]} " -v | grep -e "MasterH " -v | wc -l}" + "${grep -e " -> ${scientist[$i-1]}-Intern${j}$" server_logs.txt | grep -e "MasterH " -v | wc -l}"
    echo "Total number of hits failed = $nf"
   done
 done
